vcl 4.0;

sub vcl_hit {
    set req.http.X-Cache = "hit";
}

sub vcl_miss {
    set req.http.X-Cache = "miss";
}

sub vcl_pass {
    set req.http.X-Cache = "pass";
}

sub vcl_pipe {
    set req.http.X-Cache = "pipe uncacheable";
}

// Specify that the backend (nginx) is listening on port 8080.
backend default {
  .host = "nginx";
  .port = "8080";
}

// Allow cache-purging requests only from the following hosts.
acl purger {
  "localhost";
  "127.0.0.1";
}

sub vcl_recv {
    unset req.http.X-Cache;

    // Strip Range headers for HTML requests (stops partial content returns)
    if (req.http.Range) {
        if (req.url !~ "\.(mp4|mp3|ogg|webm|pdf)$") {
            unset req.http.Range;
        }
    }

    // Allow cache-purging requests only from the IP addresses in the above acl purger.
    // If a purge request comes from a different IP address, an error message will be produced.
    if (req.method == "PURGE") {
        if (!client.ip ~ purger) {
            return(synth(405, "This IP is not allowed to send PURGE requests."));
        }

        return (purge);
    }

    // Change the X-Forwarded-For header
    if (req.restarts == 0) {
        if (req.http.X-Forwarded-For) {
            set req.http.X-Forwarded-For = client.ip;
        }
    }

    // Exclude POST requests or those with basic authentication from caching
    if (req.http.Authorization || req.method == "POST") {
        return (pass);
    }

    // Exclude RSS feeds from caching
    if (req.url ~ "/feed") {
        return (pass);
    }

    // Don't cache the WordPress admin and login pages:
    if (req.url ~ "wp-admin|wp-login") {
        return (pass);
    }

    // Remove has_js and CloudFlare/Google Analytics __* cookies and statcounter is_unique
    set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_[_a-z]+|has_js|is_unique)=[^;]*", "");

    // Remove a ";" prefix, if present.
    set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");

    // WordPress sets many cookies that are safe to ignore.
    set req.http.cookie = regsuball(req.http.cookie, "wp-settings-\d+=[^;]+(; )?", "");
    set req.http.cookie = regsuball(req.http.cookie, "wp-settings-time-\d+=[^;]+(; )?", "");
    set req.http.Cookie = regsuball(req.http.Cookie, "wordpress_test_cookie=[^;]+(; )?", "");
    if (req.http.cookie == "") {
        unset req.http.cookie;
    }
}

// Redirect HTTP to HTTPS.
sub vcl_synth {
    set resp.http.X-Cache = "synth synth";

    if (resp.status == 850) {
        set resp.http.Location = req.http.x-redir;
        set resp.status = 302;
        return (deliver);
    }
}

// Cache-purging for a particular page must occur each time we make edits
// to that page.
sub vcl_purge {
    set req.method = "GET";
    set req.http.X-Purger = "Purged";
    return (restart);
}


// The sub vcl_backend_response directive is used to handle communication
// with the backend server, nginx. We use it to set the amount of time
// the content remains in the cache.
// We can also set a grace period, which determines how Varnish will serve
// content from the cache even if the backend server is down.
// - Time can be set in seconds (s), minutes (m), hours (h) or days (d).
// Here, we’ve set the caching time to 24 hours, and the grace period to
// 1 hour, but you can adjust these settings based on your needs.
sub vcl_backend_response {
    set beresp.ttl = 4h;
    set beresp.grace = 1h;

    if (beresp.status == 206) {
        // Don't cache partial responses (range header)
        set beresp.uncacheable = true;
        return(deliver);
    }

    if (bereq.url !~ "wp-admin|wp-login|product|cart|checkout|my-account|/?remove_item=") {
        unset beresp.http.set-cookie;
    }
}

// Change the headers for purge requests.
sub vcl_deliver {
    if (req.http.X-Purger) {
        set resp.http.X-Purger = req.http.X-Purger;
    }

    if (obj.uncacheable) {
        set req.http.X-Cache = req.http.X-Cache + " uncacheable" ;
    } else {
        set req.http.X-Cache = req.http.X-Cache + " cached" ;
    }

    // set X-Cache header in response
    set resp.http.X-Cache = req.http.X-Cache;
}
