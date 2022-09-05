--PEGAFLARE LUA FIREWALL

local os = os
local string = string
local math = math
local table = table
local tonumber = tonumber
local tostring = tostring
local next = next
local secret = " pegacdn"
local remote_addr = "auto" --Default Automatically get the Clients IP address
local expire_time = 30
local javascript_REQUEST_TYPE = 2
local refresh_auth = 5
local JavascriptVars_opening = [[
if(!window._phantom || !window.callPhantom){/*phantomjs*/
if(!window.__phantomas){/*phantomas PhantomJS-based web perf metrics + monitoring tool*/
if(!window.Buffer){/*nodejs*/
if(!window.emit){/*couchjs*/
if(!window.spawn){/*rhino*/
if(!window.webdriver){/*selenium*/
if(!window.domAutomation || !window.domAutomationController){/*chromium based automation driver*/
if(!window.document.documentElement.getAttribute("webdriver")){
/*if(navigator.userAgent){*/
if(!/bot|kodi|xbmc|wget|urllib|python|winhttp|httrack|alexa|ia_archiver|facebook|twitter|linkedin|pingdom/i.test(navigator.userAgent)){
/*if(navigator.cookieEnabled){*/
/*if(document.cookie.match(/^(?:.*;)?\s*[0-9a-f]{32}\s*=\s*([^;]+)(?:.*)?$/)){*//*HttpOnly Cookie flags prevent this*/
]]
local JavascriptVars_closing = [[
/*}*/
/*}*/
}
/*}*/
}
}
}
}
}
}
}
}
]]
local JavascriptPuzzleVars = [[parseInt("]] .. os.date("%Y%m%d",os.time()-24*60*60) .. [[", 10) + parseInt("]] .. os.date("%d%m%Y",os.time()-24*60*60) ..[[", 10)]] --Javascript output of our two random numbers
local JavascriptPuzzleVars_answer = os.date("%Y%m%d",os.time()-24*60*60) + os.date("%d%m%Y",os.time()-24*60*60) --lua output of our two random numbers
local JavascriptPuzzleVars_answer = math.floor(JavascriptPuzzleVars_answer+0.5) --fix bug removing the 0. decimal on the end of the figure
local JavascriptPuzzleVars_answer = tostring(JavascriptPuzzleVars_answer) --convert the numeric output to a string
local x_auth_header = 2 --Default 2
local x_auth_header_name = "x-auth-answer" --the header our server will expect the client to send us with the javascript answer this will change if you set the config as dynamic
local challenge = "__pega-id" --this is the first main unique identification of our cookie name
local cookie_name_start_date = challenge.."_start_date" --our cookie start date name of our firewall
local cookie_name_end_date = challenge.."_end_date" --our cookie end date name of our firewall
local cookie_name_encrypted_start_and_end_date = challenge.."_combination" --our cookie challenge unique id name
local encrypt_anti_ddos_cookies = 2 --Default 2
local encrypt_javascript_output = 0
local ip_whitelist_remote_addr = "auto" --Automatically get the Clients IP address
local ip_whitelist = {
--Alexa Bot IP
"204.236.235.245","75.101.186.145",
--Dot Bot IP
"216.244.66.196",
--GTmetrix IP
"208.70.247.157","204.187.14.70","2607:fcc0:6::110","204.187.14.71","2607:fcc0:6::111","204.187.14.72","2607:fcc0:6::112","204.187.14.73","2607:fcc0:6::113","204.187.14.74","2607:fcc0:6::114","204.187.14.75","2607:fcc0:6::115","204.187.14.76","2607:fcc0:6::116","204.187.14.77","2607:fcc0:6::117","204.187.14.78","2607:fcc0:6::118","199.10.31.194","2607:fcc0:6::119","199.10.31.195","2607:fcc0:6::120","199.10.31.196","2607:fcc0:6::121","199.10.31.197","2607:fcc0:6::122","199.10.31.198","2607:fcc0:6::123","199.10.31.199","2607:fcc0:6::124","199.10.31.200","2607:fcc0:6::125","13.85.80.124","13.84.146.132","13.84.146.226","40.74.254.217","13.84.43.227","104.214.75.209","172.255.61.34","172.255.61.35","2607:fcc0:4000:5::102","172.255.61.36","2607:fcc0:4000:5::103","172.255.61.37","2607:fcc0:4000:5::104","2607:fcc0:4000:5::104","172.255.61.38","2607:fcc0:4000:5::105","172.255.61.39","2607:fcc0:4000:5::106","172.255.61.40","2607:fcc0:4000:5::107","13.70.66.20","52.147.27.127","191.235.85.154","191.235.86.0","52.66.75.147","52.175.28.116",
--Semrush Bot IP
"46.229.168.0/24",
--Baidu Bot IP
"180.76.15.0/24","119.63.196.0/24","115.239.212.0/24","119.63.199.0/24","122.81.208.0/22","123.125.71.0/24","180.76.4.0/24","180.76.5.0/24","180.76.6.0/24","185.10.104.0/24","220.181.108.0/24","220.181.51.0/24","111.13.202.0/24","123.125.67.144/29","123.125.67.152/31","61.135.169.0/24","123.125.68.68/30","123.125.68.72/29","123.125.68.80/28","123.125.68.96/30","202.46.48.0/20","220.181.38.0/24","123.125.68.80/30","123.125.68.84/31","123.125.68.0/24",
--Bing Bot IP
"65.52.104.0/24","65.52.108.0/22","65.55.24.0/24","65.55.52.0/24","65.55.55.0/24","65.55.213.0/24","65.55.217.0/24","131.253.24.0/22","131.253.46.0/23","40.77.167.0/24","199.30.27.0/24","157.55.16.0/23","157.55.18.0/24","157.55.32.0/22","157.55.36.0/24","157.55.48.0/24","157.55.109.0/24","157.55.110.40/29","157.55.110.48/28","157.56.92.0/24","157.56.93.0/24","157.56.94.0/23","157.56.229.0/24","199.30.16.0/24","207.46.12.0/23","207.46.192.0/24","207.46.195.0/24","207.46.199.0/24","207.46.204.0/24","157.55.39.0/24",
--Duckduck Bot IP
"46.51.197.88","46.51.197.89","50.18.192.250","50.18.192.251","107.21.1.61","176.34.131.233","176.34.135.167","184.72.106.52","184.72.115.86",
--Facebook Bot IP
"31.13.107.0/24","31.13.109.0/24","31.13.200.0/24","66.220.144.0/20","69.63.189.0/24","69.63.190.0/24","69.171.224.0/20","69.171.240.0/21","69.171.248.0/24","173.252.73.0/24","173.252.74.0/24","173.252.77.0/24","173.252.100.0/22","173.252.104.0/21","173.252.112.0/24","2a03:2880:10::/48","2a03:2880:11::/48","2a03:2880:20::/48","2a03:2880:1010::/48","2a03:2880:1020::/48","2a03:2880:2020::/48","2a03:2880:2050::/48","2a03:2880:2040::/48","2a03:2880:2110::/48","2a03:2880:2130::/48","2a03:2880:3010::/48","2a03:2880:3020::/48",
--Google Bot IP
"203.208.32.0/19","66.249.64.0/19","72.14.192.0/18","209.85.128.0/17","2001:4860::/32",
--Yahoo Bot IP
"67.195.0.0/16","68.180.128.0/17","72.30.0.0/16","74.6.0.0/16","98.136.0.0/14","114.111.64.0/18","124.83.128.0/19","183.79.32.0/19","203.216.224.0/19",
--Yandex Bot IP
"178.154.128.0/17","100.43.64.0/19","37.9.64.0/19","37.140.128.0/19","77.88.0.0/18","84.201.128.0/18","87.250.224.0/19","93.158.128.0/18","95.108.128.0/17","130.193.32.0/19","141.8.128.0/18","5.45.192.0/18","5.255.192.0/18","199.21.96.0/22",
--PAYTR ODEME IP
"185.187.184.84","185.198.199.171","195.244.55.195",
--PEGAFLARE IP
"51.81.254.160/27","148.251.212.0/27",
--UptimeRobot IP
"216.144.250.150","69.162.124.226","69.162.124.227","69.162.124.228","69.162.124.229","69.162.124.230","69.162.124.231","69.162.124.232","69.162.124.233","69.162.124.233","69.162.124.234","69.162.124.235","69.162.124.236","69.162.124.237","63.143.42.242","63.143.42.243","63.143.42.244","63.143.42.245","63.143.42.246","63.143.42.247","63.143.42.248","63.143.42.249","63.143.42.250","63.143.42.251","63.143.42.252","63.143.42.253","216.245.221.82","216.245.221.83","216.245.221.84","216.245.221.85","216.245.221.86","216.245.221.87","216.245.221.88","216.245.221.89","216.245.221.90","216.245.221.91","216.245.221.92","216.245.221.93","46.137.190.132","122.248.234.23","188.226.183.141","178.62.52.237","54.79.28.129","54.94.142.218","104.131.107.63","54.67.10.127","54.64.67.106","159.203.30.41","46.101.250.135","18.221.56.27","52.60.129.180","159.89.8.111","146.185.143.14","139.59.173.249","165.227.83.148","128.199.195.156","138.197.150.151","34.233.66.117","2607:ff68:107::3","2607:ff68:107::4","2607:ff68:107::5","2607:ff68:107::6","2607:ff68:107::7","2607:ff68:107::8","2607:ff68:107::9","2607:ff68:107::10","2607:ff68:107::11","2607:ff68:107::12","2607:ff68:107::13","2607:ff68:107::14","2607:ff68:107::15","2607:ff68:107::16","2607:ff68:107::17","2607:ff68:107::18","2607:ff68:107::19","2607:ff68:107::20","2607:ff68:107::21","2607:ff68:107::22","2607:ff68:107::23","2607:ff68:107::24","2607:ff68:107::25","2607:ff68:107::26","2607:ff68:107::27","2607:ff68:107::28","2607:ff68:107::29","2607:ff68:107::30","2607:ff68:107::31","2607:ff68:107::32","2607:ff68:107::33","2607:ff68:107::34","2607:ff68:107::35","2607:ff68:107::36","2607:ff68:107::37","2607:ff68:107::38","2a03:b0c0:0:1010::832:1","2a03:b0c0:1:d0::e54:a001","2604:a880:800:10::4e6:f001","2604:a880:cad:d0::122:7001","2a03:b0c0:3:d0::33e:4001","2600:1f16:775:3a01:70d6:601a:1eb5:dbb9","2600:1f11:56a:9000:23:651b:dac0:9be4","2a03:b0c0:3:d0::44:f001","2a03:b0c0:0:1010::2b:b001","2a03:b0c0:1:d0::22:5001","2604:a880:400:d0::4f:3001","2400:6180:0:d0::16:d001","2604:a880:cad:d0::18:f001","2600:1f18:179:f900:88b2:b3d:e487:e2f4",
--Cron-job.org IP
"116.203.129.16",
}
local ip_blacklist_remote_addr = "auto" --Automatically get the Clients IP address
local ip_blacklist = {
--
}
local tor = 1 --Allow Tor Users
local tor_remote_addr = ngx.var.http_user_agent
local x_tor_header = 2 --Default 2
local x_tor_header_name = "x-tor" --tor header name
local x_tor_header_name_allowed = "true" --tor header value when we want to allow access
local x_tor_header_name_blocked = "blocked" --tor header value when we want to block access
local cookie_tor = challenge.."_tor" --our tor cookie
local cookie_tor_value_allow = "allow" --the value of the cookie when we allow access
local cookie_tor_value_block = "deny" --the value of the cookie when we block access
local default_charset = "utf-8"
local ddos_protected = 1 --enabled by default
local ddos_protected_custom_hosts = {
	{
		1, --run auth checks
		"localhost/ddos.*", --authenticate Tor websites
	},
	{
		1, --run auth checks
		".onion/.*", --authenticate Tor websites
	},
	{
		1, --run auth checks
		"github.com/.*", --authenticate github
	},
	--[[
	{
		1, --run auth checks
		"localhost",
	}, --authenticate localhost
	]]
	--[[
	{
		1, --run auth checks
		"127.0.0.1",
	}, --authenticate localhost
	]]
	--[[
	{
		1, --run auth checks
		".com",
	}, --authenticate .com domains
	]]
}
local powered_by = 1 --enabled by default
local dynamic_javascript_vars_length = 2 --dynamic default
local dynamic_javascript_vars_length_static = 10 --how many chars in length should static be
local dynamic_javascript_vars_length_start = 1 --for dynamic randomize min value to max this is min value
local dynamic_javascript_vars_length_end = 10 --for dynamic randomize min value to max this is max value
local user_agent_blacklist_var = ngx.var.http_user_agent
local user_agent_blacklist_table = {
	{
		"^$",
		3,
	}, --blocks blank / empty user-agents
	{
		"Kodi",
		1,
	},
	{
		"XBMC",
		1,
	},
	{
		"winhttp",
		1,
	},
	{
		"HTTrack",
		1,
	},
	{
		"libwww-perl",
		1,
	},
	{
		"python",
		1,
	},
}
local user_agent_whitelist_var = ngx.var.http_user_agent
local user_agent_whitelist_table = {
	{
		"^Mozilla%/5%.0 %(compatible%; Googlebot%/2%.1%; %+http%:%/%/www%.google%.com%/bot%.html%)$",
		2,
	},
	{
		"^Mozilla%/5%.0 (X11; Linux x86_64; GTmetrix% https://gtmetrix.com/)$",
		2,
	},
	{
		"^Mozilla%/5%.0 %(compatible%; Bingbot%/2%.0%; %+http%:%/%/www%.bing%.com%/bingbot%.htm%)$",
		2,
	},
	{
		"^Mozilla%/5%.0 %(compatible%; Yahoo%! Slurp%; http%:%/%/help%.yahoo%.com%/help%/us%/ysearch%/slurp%)$",
		2,
	},
	{
		"^DuckDuckBot%/1%.0%; %(%+http%:%/%/duckduckgo%.com%/duckduckbot%.html%)$",
		2,
	},
	{
		"^Mozilla%/5%.0 %(compatible%; Baiduspider%/2%.0%; %+http%:%/%/www%.baidu%.com%/search%/spider%.html%)$",
		2,
	},
	{
		"^Mozilla%/5%.0 %(compatible%; YandexBot%/3%.0%; %+http%:%/%/yandex%.com%/bots%)$",
		2,
	},
	{
		"^facebot$",
		2,
	},
	{
		"^facebookexternalhit%/1%.0 %(%+http%:%/%/www%.facebook%.com%/externalhit_uatext%.php%)$",
		2,
	},
	{
		"^facebookexternalhit%/1%.1 %(%+http%:%/%/www%.facebook%.com%/externalhit_uatext%.php%)$",
		2,
	},
	{
		"^ia_archiver %(%+http%:%/%/www%.alexa%.com%/site%/help%/webmasters%; crawler%@alexa%.com%)$",
		2,
	},
}
local authorization = 0
local authorization_paths = {
	{
		1, --show auth box on this path
		"localhost/ddos.*", --regex paths i recommend having the domain in there too
		1, --display username/password
	},
	{
		1, --show auth box on this path
		".onion/administrator.*", --regex paths i recommend having the domain in there too
		0, --do NOT display username/password
	},
	{
		1, --show auth box on this path
		".com/admin.*", --regex paths i recommend having the domain in there too
		0, --do NOT display username/password
	},
	--[[
	{ --Show on All sites and paths
		1, --show auth box on this path
		".*", --match all sites/domains paths
		1, --display username/password
	},
	]]
}
local authorization_dynamic = 0 --Static will use list
local authorization_dynamic_length = 5 --max length of our dynamic generated username and password
local authorization_message = "Restricted Area " --Message to be displayed with box
local authorization_username_message = "Your username is :" --Message to show username
local authorization_password_message = "Your password is :" --Message to show password

local authorization_logins = { --static password list
	{
		"userid1", --username
		"pass1", --password
	},
	{
		"userid2", --username
		"pass2", --password
	},
}
local authorization_cookie = challenge.."_authorization" --our authorization cookie
local WAF_POST_Request_table = {
--[[
	{
		"^task$", --match post data in requests with value task
		".*", --matching any
	},
	{
		"^name1$", --regex match
		"^.*y$", --regex or exact match
	},
]]
}
local WAF_Header_Request_table = {
--[[
	{
		"^foo$", --match header name
		".*", --matching any value
	},
	{
		"^user-agent$", --header name
		"^.*MJ12Bot.*$", --block a bad bot with user-agent header
	},
	{
		"^cookie$", --Block a Cookie Exploit
		".*SNaPjpCNuf9RYfAfiPQgklMGpOY.*",
	},
]]
}
local WAF_query_string_Request_table = {
	--[[
		PHP easter egg exploit blocking
		[server with expose_php = on]
		.php?=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000
		.php?=PHPE9568F34-D428-11d2-A769-00AA001ACF42
		.php?=PHPE9568F35-D428-11d2-A769-00AA001ACF42
		.php?=PHPE9568F36-D428-11d2-A769-00AA001ACF42
	]]
	{
		"^.*$", --match any name
		"^PHP.*$", --matching any value
	},
	{
		"base64%_encode", --regex match name
		"^.*$", --regex or exact match value
	},
	{
		"base64%_decode", --regex match name
		"^.*$", --regex or exact match value
	},
	--[[
		File injection protection

	{
		"[a-zA-Z0-9_]", --regex match name
		"http%:%/%/", --regex or exact match value
	},
	{
		"[a-zA-Z0-9_]", --regex match name
		"https%:%/%/", --regex or exact match value
	},
		]]
	--[[
		SQLi SQL Injections
	]]
	{
		"^.*$",
		"union.*select.*%(",
	},
	{
		"^.*$",
		"concat.*%(",
	},
	{
		"^.*$",
		"union.*all.*select.*",
	},
}
local WAF_URI_Request_table = {
	{
		"^.*$", --match any website on server
		".*%.htaccess.*", --protect apache server .htaccess files
	},
	{
		"^.*$", --match any website on server
		".*config%.php.*", --protect config files
	},
	{
		"^.*$", --match any website on server
		".*configuration%.php.*", --protect joomla configuration.php files
	},
	--[[
		Disallow direct access to system directories
	]]
	{
		"^.*$", --match any website on server
		".*%/cache.*", --protect /cache folder
	},
}
local query_string_sort_table = {
	{
		".*", --regex match any site / path
		1, --enable
	},
	{
		"domain.com/.*", --regex match this domain
		1, --enable
	},
}
local query_string_remove_args_table = {
	{
		".*", --all sites
		{ --query strings to remove to improve Cache HIT Ratios and Stop attacks / Cache bypassing and Busting.
			--Cloudflare cache busting query strings (get added to url from captcha and javascript pages very naughty breaking sites caches)
			"__cf_chl_jschl_tk__",
			"__cf_chl_captcha_tk__",
			--facebook cache busting query strings
			"fb_action_ids",
			"fb_action_types",
			"fb_source",
			"fbclid",
			--google cache busting query strings
			"_ga",
			"gclid",
			"utm_source",
			"utm_campaign",
			"utm_medium",
			"utm_expid",
			"utm_term",
			"utm_content",
			--other cache busting query strings
			"cache",
			"caching",
			"age-verified",
			"ao_noptimize",
			"usqp",
			"cn-reloaded",
			"dos",
			"ddos",
			"lol",
			"rnd",
			"random",
			"v", --some urls use ?v1.2 as a file version causing cache busting
			"ver",
			"version",
		},
	},
	{
		"domain.com/.*", --this site
		{ --query strings to remove to improve Cache HIT Ratios and Stop attacks / Cache bypassing and Busting.
			--facebook cache busting query strings
			"fbclid",
		},
	},
}
local send_ip_to_backend_custom_headers = {
	{
		".*",
		{
			{"CF-Connecting-IP",}, --CF-Connecting-IP Cloudflare CDN
			{"True-Client-IP",}, --True-Client-IP Akamai CDN
			{"X-Client-IP",} --Amazon Cloudfront
		},
	},
}
local custom_headers = {
	{
		".*",
		{ --headers to improve server security for all websites
			{"Server",nil,}, --Server version / identity exposure remove
			{"X-Powered-By",nil,}, --PHP Powered by version / identity exposure remove
			{"X-Content-Encoded-By",nil,}, --Joomla Content encoded by remove
			{"X-Content-Type-Options","nosniff",}, --block MIME-type sniffing
			{"x-turbo-charged-by",nil,}, --remove x-turbo-charged-by LiteSpeed
		},
	},
	{
		"%/.*%.js",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.css",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.ico",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.jpg",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.jpeg",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.bmp",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.gif",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.xml",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.txt",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.png",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.swf",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.pdf",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.zip",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.rar",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.7z",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.woff2",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.woff",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.wof",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.eot",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.ttf",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.svg",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.ejs",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.ps",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.pict",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.webp",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.eps",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.pls",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.csv",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.mid",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.doc",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.ppt",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.tif",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.xls",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.otf",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.jar",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	--video file formats
	{
		"%/.*%.mp4",
		{
			{"X-Frame-Options","SAMEORIGIN",}, --this file can only be embeded within a iframe on the same domain name stops hotlinking and leeching
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.webm",
		{
			{"X-Frame-Options","SAMEORIGIN",}, --this file can only be embeded within a iframe on the same domain name stops hotlinking and leeching
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.ogg",
		{
			{"X-Frame-Options","SAMEORIGIN",}, --this file can only be embeded within a iframe on the same domain name stops hotlinking and leeching
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.flv",
		{
			{"X-Frame-Options","SAMEORIGIN",}, --this file can only be embeded within a iframe on the same domain name stops hotlinking and leeching
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.mov",
		{
			{"X-Frame-Options","SAMEORIGIN",}, --this file can only be embeded within a iframe on the same domain name stops hotlinking and leeching
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	--music file formats
	{
		"%/.*%.mp3",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.m4a",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.aac",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.oga",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.flac",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
	{
		"%/.*%.wav",
		{
			{"Cache-Control","max-age=315360000, stale-while-revalidate=315360000, stale-if-error=315360000, public, immutable",}, --cache headers to save server bandwidth.
			{"Pragma","public",},
		},
	},
}
local ngx_re_options = "jo" --boost regex performance by caching
local scheme = ngx.var.scheme --scheme is HTTP or HTTPS
local host = ngx.var.host --host is website domain name
local request_uri = ngx.var.request_uri --request uri is full URL link including query strings and arguements
local URL = scheme .. "://" .. host .. request_uri
local pega_id = ngx.var.request_id
local user_agent = ngx.var.http_user_agent --user agent of browser
local function header_modification()
	local custom_headers_length = #custom_headers
	for i=1,custom_headers_length do --for each host in our table
		local v = custom_headers[i]
		if string.match(URL, v[1]) then --if our host matches one in the table
			local table_length = #v[2]
			for first=1,table_length do --for each arg in our table
				local value1 = v[2][first][1]
				local value2 = v[2][first][2]
				if value1 ~= nil and value2 ~= nil then
					ngx.header[value1] = value2
				end
				if value2 == nil then
					ngx.header[value1] = nil --remove the header
				end
			end
		end
	end
end
header_modification()
if remote_addr == "auto" then
	if ngx.var.http_cf_connecting_ip ~= nil then
		remote_addr = ngx.var.http_cf_connecting_ip
	elseif ngx.var.http_x_forwarded_for ~= nil then
		remote_addr = ngx.var.http_x_forwarded_for
	else
		remote_addr = ngx.var.remote_addr
	end
end
if ip_whitelist_remote_addr == "auto" then
	if ngx.var.http_cf_connecting_ip ~= nil then
		ip_whitelist_remote_addr = ngx.var.http_cf_connecting_ip
	elseif ngx.var.http_x_forwarded_for ~= nil then
		ip_whitelist_remote_addr = ngx.var.http_x_forwarded_for
	else
		ip_whitelist_remote_addr = ngx.var.remote_addr
	end
end
if ip_blacklist_remote_addr == "auto" then
	if ngx.var.http_cf_connecting_ip ~= nil then
		ip_blacklist_remote_addr = ngx.var.http_cf_connecting_ip
	elseif ngx.var.http_x_forwarded_for ~= nil then
		ip_blacklist_remote_addr = ngx.var.http_x_forwarded_for
	else
		ip_blacklist_remote_addr = ngx.var.remote_addr
	end
end
local function header_append_ip()
	local custom_headers_length = #send_ip_to_backend_custom_headers
	for i=1,custom_headers_length do --for each host in our table
		local v = custom_headers[i]
		if string.match(URL, v[1]) then --if our host matches one in the table
			local table_length = #v[2]
			for first=1,table_length do --for each arg in our table
				local value1 = v[2][first][1]
				if value1 ~= nil then
					ngx.req.set_header(value1, remote_addr)
				end
			end
		end
	end
end
header_append_ip()
if string.match(string.lower(host), ".onion") then
	remote_addr = "tor"
end
if remote_addr == "tor" then
	remote_addr = tor_remote_addr
end
local function query_string_remove_args()
	local args = ngx.req.get_uri_args() --grab our query string args and put them into a table
	local modified = nil

	local query_string_remove_args_table_length = #query_string_remove_args_table
	for i=1,query_string_remove_args_table_length do --for each host in our table
		local v = query_string_remove_args_table[i]
		if string.match(URL, v[1]) then --if our host matches one in the table
			local table_length = #v[2]
			for i=1,table_length do --for each arg in our table
				local value = v[2][i]
				args[value] = nil --remove the arguement from the args table
				modified = 1 --set args as modified
			end
			break --break out of the for each loop pointless to keep searching the rest since we matched our host
		end
	end
	if modified == 1 then --need to set our args as our new modified one
		ngx.req.set_uri_args(args) --set the args on the server as our new ordered args check ngx.var.args
	else
		return --carry on script functions
	end
end
query_string_remove_args()
local function has_value(table_, val)
	for key, value in next, table_ do
		if value == val then
			return true
		end
	end
	return false
end
local function query_string_expected_args_only()
	local args = ngx.req.get_uri_args() --grab our query string args and put them into a table
	local modified = nil

	if modified == 1 then --need to set our args as our new modified one
		ngx.req.set_uri_args(args) --set the args on the server as our new ordered args check ngx.var.args
	else
		return --carry on script functions
	end
end
query_string_expected_args_only()
local function query_string_sort()
	local allow_site = nil
	local query_string_sort_table_length = #query_string_sort_table
	for i=1,query_string_sort_table_length do --for each host in our table
		local v = query_string_sort_table[i]
		if string.match(URL, v[1]) then --if our host matches one in the table
			if v[2] == 1 then --run query string sort
				allow_site = 2 --run query string sort
			end
			if v[2] == 0 then --bypass
				allow_site = 1 --do not run query string sort
			end
			break --break out of the for each loop pointless to keep searching the rest since we matched our host
		end
	end
	if allow_site == 2 then --sort our query string
		local args = ngx.req.get_uri_args() --grab our query string args and put them into a table
		table.sort(args) --sort our query string args table into order
		ngx.req.set_uri_args(args) --set the args on the server as our new ordered args check ngx.var.args
	else --allow_site was 1
		return --carry on script functions
	end
end
query_string_sort()
local function ip_address_in_range(input_ip, client_connecting_ip)
	if string.match(input_ip, "/") then --input ip is a subnet
		--do nothing
	else
		return
	end

	local ip_type = nil
	if string.match(input_ip, "%:") and string.match(client_connecting_ip, "%:") then --if both input and connecting ip are ipv6 addresses
		--ipv6
		ip_type = 1
	elseif string.match(input_ip, "%.") and string.match(client_connecting_ip, "%.") then --if both input and connecting ip are ipv4 addresses
		--ipv4
		ip_type = 2
	else
		return
	end
	if ip_type == nil then
		--input and connecting IP one is ipv4 and one is ipv6
		return
	end

	if ip_type == 1 then --ipv6

		local function explode(string, divide)
			if divide == '' then return false end
			local pos, arr = 0, {}
			local arr_table_length = 1
			--for each divider found
			for st, sp in function() return string.find(string, divide, pos, true) end do
				arr[arr_table_length] = string.sub(string, pos, st - 1 ) --attach chars left of current divider
				arr_table_length=arr_table_length+1
				pos = sp + 1 --jump past current divider
			end
				arr[arr_table_length] = string.sub(string, pos) -- Attach chars right of last divider
				arr_table_length=arr_table_length+1
			return arr
		end

		--[[
		Input IP
		]]
		--validate actual ip
		local a, b, ip, mask = input_ip:find('([%w:]+)/(%d+)')

		--get ip bits
		local ipbits = explode(ip, ':')

		--now to build an expanded ip
		local zeroblock
		local ipbits_length = #ipbits
		for i=1,ipbits_length do
			local k = i
			local v = ipbits[i]
			--length 0? we're at the :: bit
			if v:len() == 0 then
				zeroblock = k

				--length not 0 but not 4, prepend 0's
			elseif v:len() < 4 then
				local padding = 4 - v:len()
				for i = 1, padding do
					ipbits[k] = 0 .. ipbits[k]
				end
			end
		end
		if zeroblock and #ipbits < 8 then
			--remove zeroblock
			ipbits[zeroblock] = '0000'
			local padding = 8 - #ipbits

			for i = 1, padding do
				ipbits[zeroblock] = '0000'
				--ipbits_length=ipbits_length+1
			end
		end
		--[[
		End Input IP
		]]

		--[[
		Client IP
		]]
		--validate actual ip
		local a, b, clientip, mask_client = client_connecting_ip:find('([%w:]+)')

		--get ip bits
		local ipbits_client = explode(clientip, ':')

		--now to build an expanded ip
		local zeroblock_client
		local ipbits_client_length = #ipbits_client
		for i=1,ipbits_client_length do
			local k = i
			local v = ipbits_client[i]
			--length 0? we're at the :: bit
			if v:len() == 0 then
				zeroblock_client = k

				--length not 0 but not 4, prepend 0's
			elseif v:len() < 4 then
				local padding = 4 - v:len()
				for i = 1, padding do
					ipbits_client[k] = 0 .. ipbits_client[k]
				end
			end
		end
		if zeroblock_client and #ipbits_client < 8 then
			--remove zeroblock
			ipbits_client[zeroblock_client] = '0000'
			local padding = 8 - #ipbits_client

			for i = 1, padding do
				ipbits_client[zeroblock_client] = '0000'
				--ipbits_client_length=ipbits_client_length+1
			end
		end
		--[[
		End Client IP
		]]

		local expanded_ip_count = (ipbits[1] or "0000") .. ':' .. (ipbits[2] or "0000") .. ':' .. (ipbits[3] or "0000") .. ':' .. (ipbits[4] or "0000") .. ':' .. (ipbits[5] or "0000") .. ':' .. (ipbits[6] or "0000") .. ':' .. (ipbits[7] or "0000") .. ':' .. (ipbits[8] or "0000")
		expanded_ip_count = ngx.re.gsub(expanded_ip_count, ":", "", ngx_re_options)

		local client_connecting_ip_count = (ipbits_client[1] or "0000") .. ':' .. (ipbits_client[2] or "0000") .. ':' .. (ipbits_client[3] or "0000") .. ':' .. (ipbits_client[4] or "0000") .. ':' .. (ipbits_client[5] or "0000") .. ':' .. (ipbits_client[6] or "0000") .. ':' .. (ipbits_client[7] or "0000") .. ':' .. (ipbits_client[8] or "0000")
		client_connecting_ip_count = ngx.re.gsub(client_connecting_ip_count, ":", "", ngx_re_options)

		--generate wildcard from mask
		local indent = mask / 4

		expanded_ip_count = string.sub(expanded_ip_count, 0, indent)
		client_connecting_ip_count = string.sub(client_connecting_ip_count, 0, indent)

		local client_connecting_ip_expanded = ngx.re.gsub(client_connecting_ip_count, "....", "%1:", ngx_re_options)
		client_connecting_ip_expanded = ngx.re.gsub(client_connecting_ip_count, ":$", "", ngx_re_options)
		local expanded_ip = ngx.re.gsub(expanded_ip_count, "....", "%1:", ngx_re_options)
		expanded_ip = ngx.re.gsub(expanded_ip_count, ":$", "", ngx_re_options)

		local wildcardbits = {}
		local wildcardbits_table_length = 1
		for i = 0, indent - 1 do
			wildcardbits[wildcardbits_table_length] = 'f'
			wildcardbits_table_length=wildcardbits_table_length+1
		end
		for i = 0, 31 - indent do
			wildcardbits[wildcardbits_table_length] = '0'
			wildcardbits_table_length=wildcardbits_table_length+1
		end
		--convert into 8 string array each w/ 4 chars
		local count, index, wildcard = 1, 1, {}
		local wildcardbits_length = #wildcardbits
		for i=1,wildcardbits_length do
			local k = i
			local v = wildcardbits[i]
			if count > 4 then
				count = 1
				index = index + 1
			end
			if not wildcard[index] then wildcard[index] = '' end
			wildcard[index] = wildcard[index] .. v
			count = count + 1
		end

			--loop each letter in each ipbit group
			local topip = {}
			local bottomip = {}
			local ipbits_length = #ipbits
			for i=1,ipbits_length do
				local k = i
				local v = ipbits[i]
				local topbit = ''
				local bottombit = ''
				for i = 1, 4 do
					local wild = wildcard[k]:sub(i, i)
					local norm = v:sub(i, i)
					if wild == 'f' then
						topbit = topbit .. norm
						bottombit = bottombit .. norm
					else
						topbit = topbit .. '0'
						bottombit = bottombit .. 'f'
					end
				end
				topip[k] = topbit
				bottomip[k] = bottombit
			end

		--count ips in mask
		local ipcount = math.pow(2, 128 - mask)

		if expanded_ip == client_connecting_ip_expanded then
			--print("ipv6 is in range")
			return true
		end

		--output
		--[[
		print()
		print('indent' .. indent)
		print('client_ip numeric : ' .. client_connecting_ip_count )
		print('input ip numeric : ' .. expanded_ip_count )
		print('client_ip : ' .. client_connecting_ip_expanded )
		print('input ip : ' .. expanded_ip )
		print()
		print( '###### INFO ######' )
		print( 'IP in: ' .. ip )
		print( '=> Expanded IP: ' .. (ipbits[1] or "0000") .. ':' .. (ipbits[2] or "0000") .. ':' .. (ipbits[3] or "0000") .. ':' .. (ipbits[4] or "0000") .. ':' .. (ipbits[5] or "0000") .. ':' .. (ipbits[6] or "0000") .. ':' .. (ipbits[7] or "0000") .. ':' .. (ipbits[8] or "0000") )
		print( 'Mask in: /' .. mask )
		print( '=> Mask Wildcard: ' .. (wildcard[1] or "0000") .. ':' .. (wildcard[2] or "0000") .. ':' .. (wildcard[3] or "0000") .. ':' .. (wildcard[4] or "0000") .. ':' .. (wildcard[5] or "0000") .. ':' .. (wildcard[6] or "0000") .. ':' .. (wildcard[7] or "0000") .. ':' .. (wildcard[8] or "0000") )
		print( '\n###### BLOCK ######' )
		print( '#IP\'s: ' .. ipcount )
		print( 'Range Start: ' .. (topip[1] or "0000") .. ':' .. (topip[2] or "0000") .. ':' .. (topip[3] or "0000") .. ':' .. (topip[4] or "0000") .. ':' .. (topip[5] or "0000") .. ':' .. (topip[6] or "0000") .. ':' .. (topip[7] or "0000") .. ':' .. (topip[8] or "0000") )
		print( 'Range End: ' .. (bottomip[1] or "ffff") .. ':' .. (bottomip[2] or "ffff") .. ':' .. (bottomip[3] or "ffff") .. ':' .. (bottomip[4] or "ffff") .. ':' .. (bottomip[5] or "ffff") .. ':' .. (bottomip[6] or "ffff") .. ':' .. (bottomip[7] or "ffff") .. ':' .. (bottomip[8] or "ffff") )
		]]

	end

	if ip_type == 2 then --ipv4

		local a, b, ip1, ip2, ip3, ip4, mask = input_ip:find('(%d+).(%d+).(%d+).(%d+)/(%d+)')
		local ip = { tonumber( ip1 ), tonumber( ip2 ), tonumber( ip3 ), tonumber( ip4 ) }
		local a, b, client_ip1, client_ip2, client_ip3, client_ip4 = client_connecting_ip:find('(%d+).(%d+).(%d+).(%d+)')
		local client_ip = { tonumber( client_ip1 ), tonumber( client_ip2 ), tonumber( client_ip3 ), tonumber( client_ip4 ) }

		--list masks => wildcard
		local masks = {
			[1] = { 127, 255, 255, 255 },
			[2] = { 63, 255, 255, 255 },
			[3] = { 31, 255, 255, 255 },
			[4] = { 15, 255, 255, 255 },
			[5] = { 7, 255, 255, 255 },
			[6] = { 3, 255, 255, 255 },
			[7] = { 1, 255, 255, 255 },
			[8] = { 0, 255, 255, 255 },
			[9] = { 0, 127, 255, 255 },
			[10] = { 0, 63, 255, 255 },
			[11] = { 0, 31, 255, 255 },
			[12] = { 0, 15, 255, 255 },
			[13] = { 0, 7, 255, 255 },
			[14] = { 0, 3, 255, 255 },
			[15] = { 0, 1, 255, 255 },
			[16] = { 0, 0, 255, 255 },
			[17] = { 0, 0, 127, 255 },
			[18] = { 0, 0, 63, 255 },
			[19] = { 0, 0, 31, 255 },
			[20] = { 0, 0, 15, 255 },
			[21] = { 0, 0, 7, 255 },
			[22] = { 0, 0, 3, 255 },
			[23] = { 0, 0, 1, 255 },
			[24] = { 0, 0, 0, 255 },
			[25] = { 0, 0, 0, 127 },
			[26] = { 0, 0, 0, 63 },
			[27] = { 0, 0, 0, 31 },
			[28] = { 0, 0, 0, 15 },
			[29] = { 0, 0, 0, 7 },
			[30] = { 0, 0, 0, 3 },
			[31] = { 0, 0, 0, 1 }
		}

		--get wildcard
		local wildcard = masks[tonumber( mask )]

		--number of ips in mask
		local ipcount = math.pow(2, ( 32 - mask ))

		--network IP (route/bottom IP)
		local bottomip = {}
		local ip_length = #ip
		for i=1,ip_length do
			local k = i
			local v = ip[i]
			--wildcard = 0?
			if wildcard[k] == 0 then
				bottomip[k] = v
			elseif wildcard[k] == 255 then
				bottomip[k] = 0
			else
				local mod = v % (wildcard[k] + 1)
				bottomip[k] = v - mod
			end
		end

		--use network ip + wildcard to get top ip
		local topip = {}
		local bottomip_length = #bottomip
		for i=1,bottomip_length do
			local k = i
			local v = bottomip[i]
			topip[k] = v + wildcard[k]
		end

		--is input ip = network ip?
		local isnetworkip = ( ip[1] == bottomip[1] and ip[2] == bottomip[2] and ip[3] == bottomip[3] and ip[4] == bottomip[4] )
		local isbroadcastip = ( ip[1] == topip[1] and ip[2] == topip[2] and ip[3] == topip[3] and ip[4] == topip[4] )

		local ip1 = tostring(ip1)
		local ip2 = tostring(ip2)
		local ip3 = tostring(ip3)
		local ip4 = tostring(ip4)
		local client_ip1 = tostring(client_ip1)
		local client_ip2 = tostring(client_ip2)
		local client_ip3 = tostring(client_ip3)
		local client_ip4 = tostring(client_ip4)
		local in_range_low_end1 = tostring(bottomip[1])
		local in_range_low_end2 = tostring(bottomip[2])
		local in_range_low_end3 = tostring(bottomip[3])
		local in_range_low_end4 = tostring(bottomip[4])
		local in_range_top_end1 = tostring(topip[1])
		local in_range_top_end2 = tostring(topip[2])
		local in_range_top_end3 = tostring(topip[3])
		local in_range_top_end4 = tostring(topip[4])

		if tonumber(mask) == 1 then --127, 255, 255, 255
			if client_ip1 >= in_range_low_end1 --in range low end
			and client_ip1 <= in_range_top_end1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 2 then --63, 255, 255, 255
			if client_ip1 >= in_range_low_end1 --in range low end
			and client_ip1 <= in_range_top_end1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 3 then --31, 255, 255, 255
			if client_ip1 >= in_range_low_end1 --in range low end
			and client_ip1 <= in_range_top_end1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 4 then --15, 255, 255, 255
			if client_ip1 >= in_range_low_end1 --in range low end
			and client_ip1 <= in_range_top_end1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 5 then --7, 255, 255, 255
			if client_ip1 >= in_range_low_end1 --in range low end
			and client_ip1 <= in_range_top_end1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 6 then --3, 255, 255, 255
			if client_ip1 >= in_range_low_end1 --in range low end
			and client_ip1 <= in_range_top_end1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 7 then --1, 255, 255, 255
			if client_ip1 >= in_range_low_end1 --in range low end
			and client_ip1 <= in_range_top_end1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 8 then --0, 255, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 9 then --0, 127, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 10 then --0, 63, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 11 then --0, 31, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 12 then --0, 15, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 13 then --0, 7, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 14 then --0, 3, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 15 then --0, 1, 255, 255
			if ip1 == client_ip1 
			and client_ip2 >= in_range_low_end2 --in range low end
			and client_ip2 <= in_range_top_end2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 16 then --0, 0, 255, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 17 then --0, 0, 127, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 18 then --0, 0, 63, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 19 then --0, 0, 31, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 20 then --0, 0, 15, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 21 then --0, 0, 7, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 22 then --0, 0, 3, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 23 then --0, 0, 1, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and client_ip3 >= in_range_low_end3 --in range low end
			and client_ip3 <= in_range_top_end3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 24 then --0, 0, 0, 255
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 25 then --0, 0, 0, 127
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 26 then --0, 0, 0, 63
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 27 then --0, 0, 0, 31
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 28 then --0, 0, 0, 15
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 29 then --0, 0, 0, 7
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 30 then --0, 0, 0, 3
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end
		if tonumber(mask) == 31 then --0, 0, 0, 1
			if ip1 == client_ip1 
			and ip2 == client_ip2 
			and ip3 == client_ip3 
			and client_ip4 >= in_range_low_end4 --in range low end
			and client_ip4 <= in_range_top_end4 then --in range top end
				return true
			end
		end

		--output
		--[[
		print()
		print( '###### INFO ######' )
		print( 'IP in: ' .. ip[1] .. '.' .. ip[2] .. '.' .. ip[3] .. '.' .. ip[4]  )
		print( 'Mask in: /' .. mask )
		print( '=> Mask Wildcard: ' .. wildcard[1] .. '.' .. wildcard[2] .. '.' .. wildcard[3] .. '.' .. wildcard[4]  )
		print( '=> in IP is network-ip: ' .. tostring( isnetworkip ) )
		print( '=> in IP is broadcast-ip: ' .. tostring( isbroadcastip ) )
		print( '\n###### BLOCK ######' )
		print( '#IP\'s: ' .. ipcount )
		print( 'Bottom/Network: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] .. '/' .. mask )
		print( 'Top/Broadcast: ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] )
		print( 'Subnet Range: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] .. ' - ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] )
		print( 'Host Range: ' .. bottomip[1] .. '.' .. bottomip[2] .. '.' .. bottomip[3] .. '.' .. bottomip[4] + 1 .. ' - ' .. topip[1] .. '.' .. topip[2] .. '.' .. topip[3] .. '.' .. topip[4] - 1 )
		]]

	end

end
--[[WAF Web Application Firewall POST Request arguments filter]]
local function WAF_Post_Requests()
	if next(WAF_POST_Request_table) ~= nil then --Check Post filter table has rules inside it

		ngx.req.read_body() --Grab the request Body
		local read_request_body_args = (ngx.req.get_body_data() or "") --Put the request body arguments into a variable
		local args = (ngx.decode_args(read_request_body_args) or "") --Put the Post args in to a table

		if next(args) ~= nil then --Check Post args table has contents	

			local arguement1 = nil --create empty variable
			local arguement2 = nil --create empty variable

			local WAF_table_length = #WAF_POST_Request_table
			for key, value in next, args do

				for i=1,WAF_table_length do
					arguement1 = nil --reset to nil each loop
					arguement2 = nil --reset to nil each loop
					local value = WAF_POST_Request_table[i] --put table value into variable
					local argument_name = value[1] or "" --get the WAF TABLE argument name or empty
					local argument_value = value[2] or "" --get the WAF TABLE arguement value or empty
					local args_name = tostring(key) or "" --variable to store POST data argument name
					local args_value = tostring(value) or "" --variable to store POST data argument value
					if string.match(args_name, argument_name) then --if the argument name in my table matches the one in the POST request
						arguement1 = 1
					end
					if string.match(args_value, argument_value) then --if the argument value in my table matches the one the POST request
						arguement2 = 1
					end
					if arguement1 and arguement2 then --if what would of been our empty vars have been changed to not empty meaning a WAF match then block the request
						local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
						return output
					end
				end
			end
		end
	end
end
WAF_Post_Requests()
--[[End WAF Web Application Firewall POST Request arguments filter]]

--[[WAF Web Application Firewall Header Request arguments filter]]
local function WAF_Header_Requests()
	if next(WAF_Header_Request_table) ~= nil then --Check Header filter table has rules inside it

		local argument_request_headers = ngx.req.get_headers() --get our client request headers and put them into a table

		if next(argument_request_headers) ~= nil then --Check Header args table has contents	

			local arguement1 = nil --create empty variable
			local arguement2 = nil --create empty variable

			local WAF_table_length = #WAF_Header_Request_table
			for key, value in next, argument_request_headers do

				for i=1,WAF_table_length do
					arguement1 = nil --reset to nil each loop
					arguement2 = nil --reset to nil each loop
					local value = WAF_Header_Request_table[i] --put table value into variable
					local argument_name = value[1] or "" --get the WAF TABLE argument name or empty
					local argument_value = value[2] or "" --get the WAF TABLE arguement value or empty
					local args_name = tostring(key) or "" --variable to store Header data argument name
					local args_value = tostring(ngx.req.get_headers()[args_name]) or ""
					if string.match(args_name, argument_name) then --if the argument name in my table matches the one in the request
						arguement1 = 1
					end
					if string.match(args_value, argument_value) then --if the argument value in my table matches the one the request
						arguement2 = 1
					end
					if arguement1 and arguement2 then --if what would of been our empty vars have been changed to not empty meaning a WAF match then block the request
						local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
						return output
					end
				end
			end
		end
	end
end
WAF_Header_Requests()
--[[End WAF Web Application Firewall Header Request arguments filter]]

--[[WAF Web Application Firewall Query String Request arguments filter]]
local function WAF_query_string_Request()
	if next(WAF_query_string_Request_table) ~= nil then --Check query string filter table has rules inside it

		local args = ngx.req.get_uri_args() --grab our query string args and put them into a table

		if next(args) ~= nil then --Check query string args table has contents

			local arguement1 = nil --create empty variable
			local arguement2 = nil --create empty variable

			local WAF_table_length = #WAF_query_string_Request_table
			for key, value in next, args do

				for i=1,WAF_table_length do
					arguement1 = nil --reset to nil each loop
					arguement2 = nil --reset to nil each loop
					local value = WAF_query_string_Request_table[i] --put table value into variable
					local argument_name = value[1] or "" --get the WAF TABLE argument name or empty
					local argument_value = value[2] or "" --get the WAF TABLE arguement value or empty
					local args_name = tostring(key) or "" --variable to store query string data argument name
					local args_value = tostring(ngx.req.get_uri_args()[args_name]) or "" --variable to store query string data argument value
					if string.match(args_name, argument_name) then --if the argument name in my table matches the one in the request
						arguement1 = 1
					end
					if string.match(args_value, argument_value) then --if the argument value in my table matches the one the request
						arguement2 = 1
					end
					if arguement1 and arguement2 then --if what would of been our empty vars have been changed to not empty meaning a WAF match then block the request
						local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
						return output
					end
				end
			end
		end
	end
end
WAF_query_string_Request()
--[[End WAF Web Application Firewall Query String Request arguments filter]]

--[[WAF Web Application Firewall URI Request arguments filter]]
local function WAF_URI_Request()
	if next(WAF_URI_Request_table) ~= nil then --Check Post filter table has rules inside it

		--[[
		Because ngx.var.uri is a bit stupid I strip the query string of the request uri.
		The reason for this it is subject to normalisation
		Consecutive / characters are replace by a single / 
		and URL encoded characters are decoded 
		but then your back end webserver / application recieve the encoded uri!?
		So to keep the security strong I match the same version your web application would need protecting from (Yes the encoded copy that could contain malicious / exploitable contents)
		]]
		local args = string.gsub(request_uri, "?.*", "") --remove the query string from the uri
		
		local WAF_table_length = #WAF_URI_Request_table
		for i=1,WAF_table_length do --for each host in our table
			local v = WAF_URI_Request_table[i]
			if string.match(URL, v[1]) then --if our host matches one in the table
				if string.match(args, v[2]) then
					local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
					return output
				end
			end
		end
	end
end
WAF_URI_Request()
--[[End WAF Web Application Firewall URI Request arguments filter]]

--function to check if ip address is whitelisted to bypass our auth
local function check_ip_whitelist(ip_table)
	local ip_table_length = #ip_table
	for i=1,ip_table_length do
		local value = ip_table[i]
		if value == ip_whitelist_remote_addr then --if our ip address matches with one in the whitelist
			local output = ngx.exit(ngx.OK) --Go to content
			return output
		elseif ip_address_in_range(value, ip_whitelist_remote_addr) == true then
			local output = ngx.exit(ngx.OK) --Go to content
			return output
		end
	end

	return --no ip was in the whitelist
end
check_ip_whitelist(ip_whitelist) --run whitelist check function

local function check_ip_blacklist(ip_table)
	local ip_table_length = #ip_table
	for i=1,ip_table_length do
		local value = ip_table[i]
		if value == ip_blacklist_remote_addr then
			local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
			return output
		elseif ip_address_in_range(value, ip_blacklist_remote_addr) == true then
			local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
			return output
		end
	end

	return --no ip was in blacklist
end
check_ip_blacklist(ip_blacklist) --run blacklist check function

local function check_user_agent_blacklist(user_agent_table)
	local user_agent_table_length = #user_agent_table
	for i=1,user_agent_table_length do
		local value = user_agent_table[i]
		if value[2] == 1 then --case insensative
			user_agent_blacklist_var = string.lower(user_agent_blacklist_var)
			value[1] = string.lower(value[1])
		end
		if value[2] == 2 then --case sensative
		end
		if value[2] == 3 then --regex case sensative
		end
		if value[2] == 4 then --regex lower case insensative
			user_agent_blacklist_var = string.lower(user_agent_blacklist_var)
		end
		if string.match(user_agent_blacklist_var, value[1])then
			local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
			return output
		end
	end

	return --no user agent was in blacklist
end
check_user_agent_blacklist(user_agent_blacklist_table) --run user agent blacklist check function

local function check_user_agent_whitelist(user_agent_table)
	local user_agent_table_length = #user_agent_table
	for i=1,user_agent_table_length do
		local value = user_agent_table[i]
		if value[2] == 1 then --case insensative
			user_agent_whitelist_var = string.lower(user_agent_whitelist_var)
			value[1] = string.lower(value[1])
		end
		if value[2] == 2 then --case sensative
		end
		if value[2] == 3 then --regex case sensative
		end
		if value[2] == 4 then --regex lower case insensative
			user_agent_whitelist_var = string.lower(user_agent_whitelist_var)
		end
		if string.match(user_agent_whitelist_var, value[1]) then
			local output = ngx.exit(ngx.OK) --Go to content
			return output
		end
	end

	return --no user agent was in whitelist
end
check_user_agent_whitelist(user_agent_whitelist_table) --run user agent whitelist check function

--to have better randomization upon encryption
math.randomseed(os.time())

--function to encrypt strings with our secret key / password provided
local function calculate_signature(str)
	local output = ngx.encode_base64(ngx.hmac_sha1(secret, str))
	output = ngx.re.gsub(output, "[+]", "-", ngx_re_options) --Replace + with -
	output = ngx.re.gsub(output, "[/]", "_", ngx_re_options) --Replace / with _
	output = ngx.re.gsub(output, "[=]", "", ngx_re_options) --Remove =
	return output
end
--calculate_signature(str)

--generate random strings on the fly
--qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
local charset = {}
local charset_table_length = 1
for i = 48,  57 do
charset[charset_table_length] = string.char(i)
charset_table_length=charset_table_length+1
end --0-9 numeric
charset[charset_table_length] = string.char(95) --insert number 95 underscore
charset_table_length=charset_table_length+1
local stringrandom_table = {} --create table to store our generated vars to avoid duplicates
local stringrandom_table_new_length = 1
local function stringrandom(length)
	--math.randomseed(os.time())
	if length > 0 then
		local output = stringrandom(length - 1) .. charset[math.random(1, #charset)]
		local duplicate_found = 0 --mark if we find a duplicate or not
		local stringrandom_table_length = #stringrandom_table
		for i=1,stringrandom_table_length do --for each value in our generated var table
			if stringrandom_table[i] == output then --if a value in our table matches our generated var
				duplicate_found = 1 --mark as duplicate var
				output = "_" .. output --append an underscore to the duplicate var
				stringrandom_table[stringrandom_table_new_length] = output --insert to the table
				stringrandom_table_new_length=stringrandom_table_new_length+1
				break --break out of for each loop since we found a duplicate
			end
		end
		if duplicate_found == 0 then --if no duplicate found
			stringrandom_table[stringrandom_table_new_length] = output --insert the output to our table
			stringrandom_table_new_length=stringrandom_table_new_length+1
		end
		return output
	else
		return ""
	end
end
--stringrandom(10)

local stringrandom_length = "" --create our random length variable
if dynamic_javascript_vars_length == 1 then --if our javascript random var length is to be static
	stringrandom_length = dynamic_javascript_vars_length_static --set our length as our static value
else --it is to be dynamic
	stringrandom_length = math.random(dynamic_javascript_vars_length_start, dynamic_javascript_vars_length_end) --set our length to be our dynamic min and max value
end

--shuffle table function
function shuffle(tbl)
	local tbl_length = #tbl
	for i = tbl_length, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

--for my javascript Hex output
local function sep(str, patt, re)
	local rstr = str:gsub(patt, "%1%" .. re)
	--local rstr = ngx.re.gsub(str, patt, "%1%" .. re, ngx_re_options) --this has a major issue no idea why need to investigate more
	return rstr:sub(1, #rstr - #re)
end

local function stringtohex(str)
	--return ngx.re.gsub(str, ".", function (c) print(tostring(c[0])) return string.format('%02X', string.byte(c[0])) end, ngx_re_options) --this has a major issue no idea why need to investigate more
	return str:gsub('.', function (c)
		return string.format('%02X', string.byte(c))
	end)
end

--encrypt_javascript function
local function encrypt_javascript(string1, type, defer_async, num_encrypt, encrypt_type, methods) --Function to generate encrypted/obfuscated output
	local output = "" --Empty var

	if type == 0 then
		type = math.random(3, 5) --Random encryption
	end

	if type == 1 or type == nil then --No encryption
		if defer_async == "0" or defer_async == nil then --Browser default loading / execution order
			output = "<script type=\"text/javascript\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. string1 .. "</script>"
		end
		if defer_async == "1" then --Defer
			output = "<script type=\"text/javascript\" defer=\"defer\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. string1 .. "</script>"
		end
		if defer_async == "2" then --Async
			output = "<script type=\"text/javascript\" async=\"async\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. string1 .. "</script>"
		end
	end

	--https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs
	--pass other encrypted outputs through this too ?
	if type == 2 then --Base64 Data URI
		local base64_data_uri = string1

		if tonumber(num_encrypt) ~= nil then --If number of times extra to rencrypt is set
			for i=1, #num_encrypt do --for each number
				string1 = ngx.encode_base64(base64_data_uri)
			end
		end

		if defer_async == "0" or defer_async == nil then --Browser default loading / execution order
			output = "<script type=\"text/javascript\" src=\"data:text/javascript;base64," .. ngx.encode_base64(string1) .. "\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\"></script>"
		end
		if defer_async == "1" then --Defer
			output = "<script type=\"text/javascript\" src=\"data:text/javascript;base64," .. ngx.encode_base64(string1) .. "\" defer=\"defer\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\"></script>"
		end
		if defer_async == "2" then --Async
			output = "<script type=\"text/javascript\" src=\"data:text/javascript;base64," .. ngx.encode_base64(string1) .. "\" async=\"async\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\"></script>"
		end
	end

	if type == 3 then --Hex
		local hex_output = stringtohex(string1) --ndk.set_var.set_encode_hex(string1) --Encode string in hex
		local hexadecimal_x = "" --Create var
		local encrypt_type_origin = encrypt_type --Store var passed to function in local var

		if tonumber(encrypt_type) == nil or tonumber(encrypt_type) <= 0 then
			encrypt_type = math.random(2, 2) --Random encryption
		end
		--I was inspired by http://www.hightools.net/javascript-encrypter.php so i built it myself
		if tonumber(encrypt_type) == 1 then
			hexadecimal_x = "%" .. sep(hex_output, "%x%x", "%") --hex output insert a char every 2 chars %x%x
		end
		if tonumber(encrypt_type) == 2 then
			hexadecimal_x = string.char(92) .. "x" .. sep(hex_output, "%x%x", string.char(92) .. "x") --hex output insert a char every 2 chars %x%x
		end

		--TODO: Fix this.
		--num_encrypt = "3" --test var
		if tonumber(num_encrypt) ~= nil then --If number of times extra to rencrypt is set
			for i=1, num_encrypt do --for each number
				if tonumber(encrypt_type) ~= nil then
					encrypt_type = math.random(1, 2) --Random encryption
					if tonumber(encrypt_type) == 1 then
						--hexadecimal_x = "%" .. sep(ndk.set_var.set_encode_hex("eval(decodeURIComponent('" .. hexadecimal_x .. "'))"), "%x%x", "%") --hex output insert a char every 2 chars %x%x
					end
					if tonumber(encrypt_type) == 2 then
						--hexadecimal_x = "\\x" .. sep(ndk.set_var.set_encode_hex("eval(decodeURIComponent('" .. hexadecimal_x .. "'))"), "%x%x", "\\x") --hex output insert a char every 2 chars %x%x
					end
				end
			end
		end

		if defer_async == "0" or defer_async == nil then --Browser default loading / execution order
			--https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent
			output = "<script type=\"text/javascript\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">eval(decodeURIComponent(escape('" .. hexadecimal_x .. "')));</script>"
		end
		if defer_async == "1" then --Defer
			output = "<script type=\"text/javascript\" defer=\"defer\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">eval(decodeURIComponent(escape('" .. hexadecimal_x .. "')));</script>"
		end
		if defer_async == "2" then --Defer
			output = "<script type=\"text/javascript\" async=\"async\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">eval(decodeURIComponent(escape('" .. hexadecimal_x .. "')));</script>"
		end
	end

	if type == 4 then --Base64 javascript decode
		local base64_javascript = "eval(decodeURIComponent(escape(window.atob('" .. ngx.encode_base64(string1) .. "'))))"

		if tonumber(num_encrypt) ~= nil then --If number of times extra to rencrypt is set
			for i=1, num_encrypt do --for each number
				base64_javascript = "eval(decodeURIComponent(escape(window.atob('" .. ngx.encode_base64(base64_javascript) .. "'))))"
			end
		end

		if defer_async == "0" or defer_async == nil then --Browser default loading / execution order
			output = "<script type=\"text/javascript\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. base64_javascript .. "</script>"
		end
		if defer_async == "1" then --Defer
			output = "<script type=\"text/javascript\" defer=\"defer\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. base64_javascript .. "</script>"
		end
		if defer_async == "2" then --Defer
			output = "<script type=\"text/javascript\" async=\"async\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. base64_javascript .. "</script>"
		end
	end

	if type == 5 then --PegaFlare's Javascript Scrambler (Obfuscate Javascript by putting it into vars and shuffling them like a deck of cards)
		local base64_javascript = ngx.encode_base64(string1) --base64 encode our script

		local l = #base64_javascript --count number of chars our variable has
		local i = 0 --keep track of how many times we pass through
		local r = math.random(1, l) --randomize where to split string
		local chunks = {} --create our chunks table for string storage
		local chunks_table_length = 1
		local chunks_order = {} --create our chunks table for string storage that stores the value only
		local chunks_order_table_length = 1
		local random_var = nil --create our random string variable to use

		while i <= l do
			random_var = stringrandom(stringrandom_length) --create a random variable name to use
			chunks_order[chunks_order_table_length] = "_" .. random_var .. "" --insert the value into our ordered table
			chunks_order_table_length=chunks_order_table_length+1
			chunks[chunks_table_length] = 'var _' .. random_var .. '="' .. base64_javascript:sub(i,i+r).. '";' --insert our value into our table we will scramble
			chunks_table_length=chunks_table_length+1

			i = i+r+1
		end

		shuffle(chunks) --scramble our table

		output = table.concat(chunks, "") --put our scrambled table into string
		output = output .. "eval(decodeURIComponent(escape(window.atob(" .. table.concat(chunks_order, " + " ) .. "))));" --put our scrambled table and ordered table into a string
		
		if defer_async == "0" or defer_async == nil then --Browser default loading / execution order
			output = "<script type=\"text/javascript\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. output .. "</script>"
		end
		if defer_async == "1" then --Defer
			output = "<script type=\"text/javascript\" defer=\"defer\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. output .. "</script>"
		end
		if defer_async == "2" then --Defer
			output = "<script type=\"text/javascript\" async=\"async\" charset=\"" .. default_charset .. "\" data-cfasync=\"false\">" .. output .. "</script>"
		end
	end

	return output
end
--end encrypt_javascript function

local currenttime = ngx.time() --Current time on server

local currentdate = "" --make current date a empty var

--Make sure our current date is in align with expires_time variable so that the auth page only shows when the cookie expires
if expire_time <= 60 then --less than equal to one minute
	currentdate = os.date("%M",os.time()-24*60*60) --Current minute
end
if expire_time > 60 then --greater than one minute
	currentdate = os.date("%H",os.time()-24*60*60) --Current hour
end
if expire_time > 3600 then --greater than one hour
	currentdate = os.date("%d",os.time()-24*60*60) --Current day of the year
end
if expire_time > 86400 then --greater than one day
	currentdate = os.date("%W",os.time()-24*60*60) --Current week
end
if expire_time > 6048000 then --greater than one week
	currentdate = os.date("%m",os.time()-24*60*60) --Current month
end
if expire_time > 2628000 then --greater than one month
	currentdate = os.date("%Y",os.time()-24*60*60) --Current year
end
if expire_time > 31536000 then --greater than one year
	currentdate = os.date("%z",os.time()-24*60*60) --Current time zone
end

local expected_header_status = 200
local authentication_page_status_output = 418

--Put our vars into storage for use later on
local challenge_original = challenge
local cookie_name_start_date_original = cookie_name_start_date
local cookie_name_end_date_original = cookie_name_end_date
local cookie_name_encrypted_start_and_end_date_original = cookie_name_encrypted_start_and_end_date

--[[
Start Tor detection
]]
if x_tor_header == 2 then --if x-tor-header is dynamic
	x_tor_header_name = calculate_signature(tor_remote_addr .. x_tor_header_name .. currentdate) --make the header unique to the client and for todays date encrypted so every 24 hours this will change and can't be guessed by bots gsub because header bug with underscores so underscore needs to be removed
	x_tor_header_name = ngx.re.gsub(x_tor_header_name, "_", "", ngx_re_options) --replace underscore with nothing
	x_tor_header_name_allowed = calculate_signature(tor_remote_addr .. x_tor_header_name_allowed .. currentdate) --make the header unique to the client and for todays date encrypted so every 24 hours this will change and can't be guessed by bots gsub because header bug with underscores so underscore needs to be removed
	x_tor_header_name_allowed = ngx.re.gsub(x_tor_header_name_allowed, "_", "", ngx_re_options) --replace underscore with nothing
	x_tor_header_name_blocked = calculate_signature(tor_remote_addr .. x_tor_header_name_blocked .. currentdate) --make the header unique to the client and for todays date encrypted so every 24 hours this will change and can't be guessed by bots gsub because header bug with underscores so underscore needs to be removed
	x_tor_header_name_blocked = ngx.re.gsub(x_tor_header_name_blocked, "_", "", ngx_re_options) --replace underscore with nothing
end

if encrypt_anti_ddos_cookies == 2 then --if Anti-DDoS Cookies are to be encrypted
	cookie_tor = calculate_signature(tor_remote_addr .. cookie_tor .. currentdate) --encrypt our tor cookie name
	cookie_tor_value_allow = calculate_signature(tor_remote_addr .. cookie_tor_value_allow .. currentdate) --encrypt our tor cookie value for allow
	cookie_tor_value_block = calculate_signature(tor_remote_addr .. cookie_tor_value_block .. currentdate) --encrypt our tor cookie value for block
end

--block tor function to block traffic from tor users
local function blocktor()
	local output = ngx.exit(ngx.HTTP_FORBIDDEN) --deny user access
	return output
end

--check the connecting client to see if they have our required matching tor cookie name in their request
local tor_cookie_name = "cookie_" .. cookie_tor
local tor_cookie_value = ngx.var[tor_cookie_name] or ""

if tor_cookie_value == cookie_tor_value_allow then --if their cookie value matches the value we expect
	if tor == 2 then --perform check if tor users should be allowed or blocked if tor users already browsing your site have been granted access and you change this setting you want them to be blocked now so this makes sure they are denied any further access before their cookie expires
		blocktor()
	end
	remote_addr = tor_remote_addr --set the remote_addr as the tor_remote_addr value
end

if tor_cookie_value == cookie_tor_value_block then --if the provided cookie value matches our block cookie value
	blocktor()
end

local cookie_tor_value = "" --create variable to store if tor should be allowed or disallowed
local x_tor_header_name_value = "" --create variable to store our expected header value

if tor == 1 then --if tor users should be allowed
	cookie_tor_value = cookie_tor_value_allow --set our value as our expected allow value
	x_tor_header_name_value = x_tor_header_name_allowed --set our value as our expected allow value
else --tor users should be blocked
	cookie_tor_value = cookie_tor_value_block --set our value as our expected block value
	x_tor_header_name_value = x_tor_header_name_blocked --set our value as our expected block value
end
--[[
End Tor detection
]]

--[[
Authorization / Restricted Access Area Box
]]
if encrypt_anti_ddos_cookies == 2 then --if Anti-DDoS Cookies are to be encrypted
	authorization_cookie = calculate_signature(remote_addr .. authorization_cookie .. currentdate) --encrypt our auth box session cookie name
end

local function check_authorization(authorization, authorization_dynamic)
	if authorization == 0 or nil then --auth box disabled
		return
	end

	local expected_cookie_value = nil
	local remote_addr = tor_remote_addr --set for compatibility with Tor Clients
	if authorization == 2 then --Cookie sessions
		local cookie_name = "cookie_" .. authorization_cookie
		local cookie_value = ngx.var[cookie_name] or ""
		expected_cookie_value = calculate_signature(remote_addr .. "authenticate" .. currentdate) --encrypt our expected cookie value
		if cookie_value == expected_cookie_value then --cookie value client gave us matches what we expect it to be
			ngx.exit(ngx.OK) --Go to content
		end
	end

	local allow_site = nil
	local authorization_display_user_details = nil
	local authorization_paths_length = #authorization_paths
	for i=1,authorization_paths_length do --for each host in our table
		local v = authorization_paths[i]
		if string.match(URL, v[2]) then --if our host matches one in the table
			if v[1] == 1 then --Showbox
				allow_site = 1 --showbox
			end
			if v[1] == 2 then --Don't show box
				allow_site = 2 --don't show box
			end
			authorization_display_user_details = v[3] --to show our username/password or to not display it
			break --break out of the for each loop pointless to keep searching the rest since we matched our host
		end
	end
	if allow_site == 1 then --checks passed site allowed grant direct access
		--showbox
	else --allow_site was 2
		return --carry on script functions to display auth page
	end

	local allow_access = nil
	local authorization_username = nil
	local authorization_password = nil

	local req_headers = ngx.req.get_headers() --get all request headers

	if authorization_dynamic == 0 then --static
		local authorization_logins_length = #authorization_logins
		for i=1,authorization_logins_length do --for each login
			local value = authorization_logins[i]
			authorization_username = value[1] --username
			authorization_password = value[2] --password
			local base64_expected = authorization_username .. ":" .. authorization_password --convert to browser format
			base64_expected = ngx.encode_base64(base64_expected) --base64 encode like browser format
			local authroization_user_pass = "Basic " .. base64_expected --append Basic to start like browser header does
			if req_headers["Authorization"] == authroization_user_pass then --if the details match what we expect
				if authorization == 2 then --Cookie sessions
					set_cookie1 = authorization_cookie.."="..expected_cookie_value.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";"
					set_cookies = {set_cookie1}
					ngx.header["Set-Cookie"] = set_cookies --send client a cookie for their session to be valid
				end
				allow_access = 1 --grant access
				break --break out foreach loop since our user and pass was correct
			end
		end
	end
	if authorization_dynamic == 1 then --dynamic
		authorization_username = calculate_signature(remote_addr .. "username" .. currentdate) --encrypt username
		authorization_password = calculate_signature(remote_addr .. "password" .. currentdate) --encrypt password
		authorization_username = string.sub(authorization_username, 1, authorization_dynamic_length) --change username to set length
		authorization_password = string.sub(authorization_password, 1, authorization_dynamic_length) --change password to set length

		local base64_expected = authorization_username .. ":" .. authorization_password --convert to browser format
		base64_expected = ngx.encode_base64(base64_expected) --base64 encode like browser format
		local authroization_user_pass = "Basic " .. base64_expected --append Basic to start like browser header does
		if req_headers["Authorization"] == authroization_user_pass then --if the details match what we expect
			if authorization == 2 then --Cookie sessions
				set_cookie1 = authorization_cookie.."="..expected_cookie_value.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";"
				set_cookies = {set_cookie1}
				ngx.header["Set-Cookie"] = set_cookies --send client a cookie for their session to be valid
			end
			allow_access = 1 --grant access
		end
	end

	if allow_access == 1 then
		ngx.exit(ngx.OK) --Go to content
	else
		ngx.status = ngx.HTTP_UNAUTHORIZED --send client unathorized header
		if authorization_display_user_details == 0 then
			ngx.header['WWW-Authenticate'] = 'Basic realm="' .. authorization_message .. '", charset="' .. default_charset .. '"' --send client a box to input required username and password fields
		else
			ngx.header['WWW-Authenticate'] = 'Basic realm="' .. authorization_message .. ' ' .. authorization_username_message .. ' ' .. authorization_username .. ' ' .. authorization_password_message .. ' ' .. authorization_password .. '", charset="' .. default_charset .. '"' --send client a box to input required username and password fields
		end
		ngx.exit(ngx.HTTP_UNAUTHORIZED) --deny access any further
	end
end
check_authorization(authorization, authorization_dynamic)
--[[
Authorization / Restricted Access Area Box
]]

--[[
master switch
]]
--master switch check
local function check_ddos_protected()
	if ddos_protected == 2 then --script disabled
		local output = ngx.exit(ngx.OK) --Go to content
		return output
	end
	if ddos_protected == 3 then --custom host selection
		local allow_site = nil
		local ddos_protected_custom_hosts_length = #ddos_protected_custom_hosts
		for i=1,ddos_protected_custom_hosts_length do --for each host in our table
			local v = ddos_protected_custom_hosts[i]
			if string.match(URL, v[2]) then --if our host matches one in the table
				if v[1] == 1 then --run auth
					allow_site = 2 --run auth checks
				end
				if v[1] == 2 then --bypass
					allow_site = 1 --bypass auth achecks
				end
				break --break out of the for each loop pointless to keep searching the rest since we matched our host
			end
		end
		if allow_site == 1 then --checks passed site allowed grant direct access
			local output = ngx.exit(ngx.OK) --Go to content
			return output
		else --allow_site was 2 to disallow direct access we matched a host to protect
			return --carry on script functions to display auth page
		end
	end
end
check_ddos_protected()
--[[
master switch
]]

local answer = calculate_signature(remote_addr) --create our encrypted unique identification for the user visiting the website.

if x_auth_header == 2 then --if x-auth-header is dynamic
	x_auth_header_name = calculate_signature(remote_addr .. x_auth_header_name .. currentdate) --make the header unique to the client and for todays date encrypted so every 24 hours this will change and can't be guessed by bots gsub because header bug with underscores so underscore needs to be removed
	x_auth_header_name = ngx.re.gsub(x_auth_header_name, "_", "", ngx_re_options) --replace underscore with nothing
end

if encrypt_anti_ddos_cookies == 2 then --if Anti-DDoS Cookies are to be encrypted
	--make the cookies unique to the client and for todays date encrypted so every 24 hours this will change and can't be guessed by bots
	challenge = calculate_signature(remote_addr .. challenge .. currentdate)
	cookie_name_start_date = calculate_signature(remote_addr .. cookie_name_start_date .. currentdate)
	cookie_name_end_date = calculate_signature(remote_addr .. cookie_name_end_date .. currentdate)
	cookie_name_encrypted_start_and_end_date = calculate_signature(remote_addr .. cookie_name_encrypted_start_and_end_date .. currentdate)
end

--[[
Grant access function to either grant or deny user access to our website
]]
local function grant_access()
	--our uid cookie
	local cookie_name = "cookie_" .. challenge
	local cookie_value = ngx.var[cookie_name] or ""
	--our start date cookie
	local cookie_name_start_date_name = "cookie_" .. cookie_name_start_date
	local cookie_name_start_date_value = ngx.var[cookie_name_start_date_name] or ""
	local cookie_name_start_date_value_unix = tonumber(cookie_name_start_date_value)
	--our end date cookie
	local cookie_name_end_date_name = "cookie_" .. cookie_name_end_date
	local cookie_name_end_date_value = ngx.var[cookie_name_end_date_name] or ""
	--our start date and end date combined to a unique id
	local cookie_name_encrypted_start_and_end_date_name = "cookie_" .. cookie_name_encrypted_start_and_end_date
	local cookie_name_encrypted_start_and_end_date_value = ngx.var[cookie_name_encrypted_start_and_end_date_name] or ""

	if cookie_value ~= answer then --if cookie value not equal to or matching our expected cookie they should be giving us
		return --return to refresh the page so it tries again
	end

	--if x-auth-answer is correct to the user unique id time stamps etc meaning browser figured it out then set a new cookie that grants access without needed these checks
	local req_headers = ngx.req.get_headers() --get all request headers
	if req_headers["x-requested-with"] == "XMLHttpRequest" then --if request header matches request type of XMLHttpRequest
		if req_headers[x_tor_header_name] == x_tor_header_name_value and req_headers[x_auth_header_name] == JavascriptPuzzleVars_answer then --if the header and value are what we expect then the client is legitimate
			remote_addr = tor_remote_addr --set as our defined static tor variable to use
			
			challenge = calculate_signature(remote_addr .. challenge_original .. currentdate) --create our encrypted unique identification for the user visiting the website again. (Stops a double page refresh loop)
			answer = calculate_signature(remote_addr) --create our answer again under the new remote_addr (Stops a double page refresh loop)
			cookie_name_start_date = calculate_signature(remote_addr .. cookie_name_start_date_original .. currentdate) --create our cookie_name_start_date again under the new remote_addr (Stops a double page refresh loop)
			cookie_name_end_date = calculate_signature(remote_addr .. cookie_name_end_date_original .. currentdate) --create our cookie_name_end_date again under the new remote_addr (Stops a double page refresh loop)
			cookie_name_encrypted_start_and_end_date = calculate_signature(remote_addr .. cookie_name_encrypted_start_and_end_date_original .. currentdate) --create our cookie_name_encrypted_start_and_end_date again under the new remote_addr (Stops a double page refresh loop)

			set_cookie1 = challenge.."="..answer.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --apply our uid cookie incase javascript setting this cookies time stamp correctly has issues
			set_cookie2 = cookie_name_start_date.."="..currenttime.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --start date cookie
			set_cookie3 = cookie_name_end_date.."="..(currenttime+expire_time).."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --end date cookie
			set_cookie4 = cookie_name_encrypted_start_and_end_date.."="..calculate_signature(remote_addr .. currenttime .. (currenttime+expire_time) ).."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --start and end date combined to unique id
			set_cookie5 = cookie_tor.."="..cookie_tor_value.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --create our tor cookie to identify the client as a tor user

			set_cookies = {set_cookie1 , set_cookie2 , set_cookie3 , set_cookie4, set_cookie5}
			ngx.header["Set-Cookie"] = set_cookies
			ngx.header["X-Content-Type-Options"] = "nosniff"
			ngx.header["X-Frame-Options"] = "SAMEORIGIN"
			ngx.header["Cache-Control"] = "public, max-age=0 no-store, no-cache, must-revalidate, post-check=0, pre-check=0"
			ngx.header["Pragma"] = "no-cache"
			ngx.header["Expires"] = "0"
			ngx.header.content_type = "text/html; charset=" .. default_charset
			ngx.status = expected_header_status
			ngx.exit(ngx.HTTP_NO_CONTENT)
		end
		if req_headers[x_auth_header_name] == JavascriptPuzzleVars_answer then --if the answer header provided by the browser Javascript matches what our Javascript puzzle answer should be
			set_cookie1 = challenge.."="..cookie_value.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --apply our uid cookie incase javascript setting this cookies time stamp correctly has issues
			set_cookie2 = cookie_name_start_date.."="..currenttime.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --start date cookie
			set_cookie3 = cookie_name_end_date.."="..(currenttime+expire_time).."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --end date cookie
			set_cookie4 = cookie_name_encrypted_start_and_end_date.."="..calculate_signature(remote_addr .. currenttime .. (currenttime+expire_time) ).."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --start and end date combined to unique id

			set_cookies = {set_cookie1 , set_cookie2 , set_cookie3 , set_cookie4}
			ngx.header["Set-Cookie"] = set_cookies
			ngx.header["X-Content-Type-Options"] = "nosniff"
			ngx.header["X-Frame-Options"] = "SAMEORIGIN"
			ngx.header["Cache-Control"] = "public, max-age=0 no-store, no-cache, must-revalidate, post-check=0, pre-check=0"
			ngx.header["Pragma"] = "no-cache"
			ngx.header["Expires"] = "0"
			ngx.header.content_type = "text/html; charset=" .. default_charset
			ngx.status = expected_header_status
			ngx.exit(ngx.HTTP_NO_CONTENT)
		end
	end

	if cookie_name_start_date_value ~= nil and cookie_name_end_date_value ~= nil and cookie_name_encrypted_start_and_end_date_value ~= nil then --if all our cookies exist
		local cookie_name_end_date_value_unix = tonumber(cookie_name_end_date_value) or nil --convert our cookie end date provided by the user into a unix time stamp
		if cookie_name_end_date_value_unix == nil or cookie_name_end_date_value_unix == "" then --if our cookie end date date in unix does not exist
			return --return to refresh the page so it tries again
		end
		if cookie_name_end_date_value_unix <= currenttime then --if our cookie end date is less than or equal to the current date meaning the users authentication time expired
			return --return to refresh the page so it tries again
		end
		if cookie_name_encrypted_start_and_end_date_value ~= calculate_signature(remote_addr .. cookie_name_start_date_value_unix .. cookie_name_end_date_value_unix) then --if users authentication encrypted cookie not equal to or matching our expected cookie they should be giving us
			return --return to refresh the page so it tries again
		end
	end
	--else all checks passed bypass our firewall and show page content

	local output = ngx.exit(ngx.OK) --Go to content
	return output
end
--grant_access()

--[[
End Required Functions
]]

grant_access() --perform checks to see if user can access the site or if they will see our denial of service status below

--[[
Build HTML Template
]]

local title = host .. [[ | PegaCDN WAF]]

if javascript_REQUEST_TYPE == 3 then --Dynamic Random request
	javascript_REQUEST_TYPE = math.random (1, 2) --Randomize between 1 and 2
end
if javascript_REQUEST_TYPE == 1 then --GET request
	javascript_REQUEST_TYPE = "GET"
end
if javascript_REQUEST_TYPE == 2 then --POST request
	javascript_REQUEST_TYPE = "POST"
end

local javascript_POST_headers = "" --Create empty var
local javascript_POST_data = "" --Create empty var

if javascript_REQUEST_TYPE == "POST" then
	-- https://www.w3schools.com/xml/tryit.asp?filename=tryajax_post2
	javascript_POST_headers = [[xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
]]

	javascript_POST_data = [["name1=Henry&name2=Ford"]]

end

local JavascriptPuzzleVariable_name = "_" .. stringrandom(stringrandom_length)

local javascript_detect_tor = [[
var sw, sh, ww, wh, v;
sw = screen.width;
sh = screen.height;
ww = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth || 0;
wh = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || 0;
if ((sw == ww) && (sh == wh)) {
    v = true;
    if (!(ww % 200) && (wh % 100)) {
        v = true;
    }
}
//v = true; //test var nulled out used for debugging purpose
if (v == true) {
	xhttp.setRequestHeader(']] .. x_tor_header_name .. [[', ']] .. x_tor_header_name_value .. [[');
}
]]
--[[
End Tor Browser Checks
]]

local javascript_REQUEST_headers = [[
xhttp.setRequestHeader(']] .. x_auth_header_name .. [[', ]] .. JavascriptPuzzleVariable_name .. [[); //make the answer what ever the browser figures it out to be
			xhttp.setRequestHeader('X-Requested-with', 'XMLHttpRequest');
			xhttp.setRequestHeader('X-Requested-TimeStamp', '');
			xhttp.setRequestHeader('X-Requested-TimeStamp-Expire', '');
			xhttp.setRequestHeader('X-Requested-TimeStamp-Combination', '');
			xhttp.setRequestHeader('X-Requested-Type', 'GET');
			xhttp.setRequestHeader('X-Requested-Type-Combination', 'GET'); //Encrypted for todays date
			xhttp.withCredentials = true;
]] .. javascript_detect_tor

local JavascriptPuzzleVariable = [[
var ]] .. JavascriptPuzzleVariable_name .. [[=]] .. JavascriptPuzzleVars ..[[;
]]

-- https://www.w3schools.com/xml/tryit.asp?filename=try_dom_xmlhttprequest
local javascript_anti_ddos = [[
(function(){
	var a = function() {try{return !!window.addEventListener} catch(e) {return !1} },
	b = function(b, c) {a() ? document.addEventListener("DOMContentLoaded", b, c) : document.attachEvent("onreadystatechange", b)};
	b(function(){
		var timeleft = ]] .. refresh_auth .. [[;
		var downloadTimer = setInterval(function(){
			timeleft--;
			document.getElementById("countdowntimer").textContent = timeleft;
			if(timeleft <= 0)
			clearInterval(downloadTimer);
		},1000);
		setTimeout(function(){
			var now = new Date();
			var time = now.getTime();
			time += 300 * 1000;
			now.setTime(time);
			document.cookie = ']] .. challenge .. [[=]] .. answer .. [[' + '; expires=' + ']] .. ngx.cookie_time(currenttime+expire_time) .. [[' + '; path=/';
			//javascript puzzle for browser to figure out to get answer
			]] .. JavascriptVars_opening .. [[
			]] .. JavascriptPuzzleVariable .. [[
			]] .. JavascriptVars_closing .. [[
			//end javascript puzzle
			var xhttp = new XMLHttpRequest();
			xhttp.onreadystatechange = function() {
				if (xhttp.readyState === 4) {
					document.getElementById("status").innerHTML = "Redirect your page.";
					location.reload(true);
				}
			};
			xhttp.open("]] .. javascript_REQUEST_TYPE .. [[", "]] .. request_uri .. [[", true);
			]] .. javascript_REQUEST_headers .. [[
			]] .. javascript_POST_headers .. [[
			xhttp.send(]] .. javascript_POST_data .. [[);
		}, ]] .. refresh_auth+1 .. [[000); /*if correct data has been sent then the auth response will allow access*/
	}, false);
})();
]]

--TODO: include Captcha like Google ReCaptcha

--[[
encrypt/obfuscate the javascript output
]]
if encrypt_javascript_output == 1 then --No encryption/Obfuscation of Javascript so show Javascript in plain text
javascript_anti_ddos = [[<script type="text/javascript" charset="]] .. default_charset .. [[" data-cfasync="false">
]] .. javascript_anti_ddos .. [[
</script>]]
else --some form of obfuscation has been specified so obfuscate the javascript output
javascript_anti_ddos = encrypt_javascript(javascript_anti_ddos, encrypt_javascript_output) --run my function to encrypt/obfuscate javascript output
end


--Adverts positions
local head_ad_slot = [[
<!-- Start: Ad code and script tags for header of page -->
<!-- End: Ad code and script tags for header of page -->
]]
local top_body_ad_slot = [[
<!-- Start: Ad code and script tags for top of page -->
<!-- End: Ad code and script tags for top of page -->
]]
local left_body_ad_slot = [[
<!-- Start: Ad code and script tags for left of page -->
<!-- End: Ad code and script tags for left of page -->
]]
local right_body_ad_slot = [[
<!-- Start: Ad code and script tags for right of page -->
<!-- End: Ad code and script tags for right of page -->
]]
local footer_body_ad_slot = [[
<!-- Start: Ad code and script tags for bottom of page -->
<!-- End: Ad code and script tags for bottom of page -->
]]
--End advert positions

local ddos_powered_by = [[
<div class="powered_by" style="text-align:center;font-size:100%;">
<a href="//www.pegaflare.com" target="_blank">DDoS protection by &copy; PegaCDN WAF</a>
</div>
]]

if powered_by == 2 then
ddos_powered_by = "" --make empty string
end

--Fix remote_addr output as what ever IP address the Client is using
if ngx.var.http_cf_connecting_ip ~= nil then
remote_addr = ngx.var.http_cf_connecting_ip
elseif ngx.var.http_x_forwarded_for ~= nil then
remote_addr = ngx.var.http_x_forwarded_for
else
remote_addr = ngx.var.remote_addr
end

local request_details = [[
<div id="status">
<noscript>Please turn JavaScript on and reload the page.<br></noscript>
</div>
<h3 style="color:#bd2426;">Request Details :</h3>
IP address : ]] .. remote_addr .. [[
<br>
PegaID : ]] .. pega_id .. [[
<br>
]]

local style_sheet = [[
@font-face{font-display:swap;font-family:Poppins;font-style:normal;font-weight:600;src:local("Poppins SemiBold"),local("Poppins-SemiBold"),url(data:font/woff2;base64,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) format("woff2");unicode-range:U+0900-097f,U+1cd0-1cf6,U+1cf8-1cf9,U+200c-200d,U+20a8,U+20b9,U+25cc,U+a830-a839,U+a8e0-a8fb}@font-face{font-display:swap;font-family:Poppins;font-style:normal;font-weight:600;src:local("Poppins SemiBold"),local("Poppins-SemiBold"),url(data:font/woff2;base64,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) format("woff2");unicode-range:U+0100-024f,U+0259,U+1e??,U+2020,U+20a0-20ab,U+20ad-20cf,U+2113,U+2c60-2c7f,U+a720-a7ff}@font-face{font-display:swap;font-family:Poppins;font-style:normal;font-weight:600;src:local("Poppins SemiBold"),local("Poppins-SemiBold"),url(data:font/woff2;base64,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) format("woff2");unicode-range:U+00??,U+0131,U+0152-0153,U+02bb-02bc,U+02c6,U+02da,U+02dc,U+2000-206f,U+2074,U+20ac,U+2122,U+2191,U+2193,U+2212,U+2215,U+feff,U+fffd}@font-face{font-display:swap;font-family:Poppins;font-style:normal;font-weight:700;src:local("Poppins Bold"),local("Poppins-Bold"),url(data:font/woff2;base64,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) format("woff2");unicode-range:U+0900-097f,U+1cd0-1cf6,U+1cf8-1cf9,U+200c-200d,U+20a8,U+20b9,U+25cc,U+a830-a839,U+a8e0-a8fb}@font-face{font-display:swap;font-family:Poppins;font-style:normal;font-weight:700;src:local("Poppins Bold"),local("Poppins-Bold"),url(data:font/woff2;base64,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) format("woff2");unicode-range:U+0100-024f,U+0259,U+1e??,U+2020,U+20a0-20ab,U+20ad-20cf,U+2113,U+2c60-2c7f,U+a720-a7ff}@font-face{font-display:swap;font-family:Poppins;font-style:normal;font-weight:700;src:local("Poppins Bold"),local("Poppins-Bold"),url(data:font/woff2;base64,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) format("woff2");unicode-range:U+00??,U+0131,U+0152-0153,U+02bb-02bc,U+02c6,U+02da,U+02dc,U+2000-206f,U+2074,U+20ac,U+2122,U+2191,U+2193,U+2212,U+2215,U+feff,U+fffd}</style>
	<style type="text/css" media="screen">*,:after,:before{box-sizing:border-box}body,html{font-family:Poppins,sans-serif;height:100%;margin:0;padding:0;text-align:center;width:100%}header img,header svg{-webkit-animation-duration:.75s;-webkit-animation-fill-mode:both;-webkit-animation-name:fastzid;animation-duration:.75s;animation-fill-mode:both;animation-name:fastzid;margin:40px auto 20px}main h1{color:#3e4154;font-size:32px;font-weight:700}main h1,main p{margin:0 auto;max-width:550px;padding:10px}main p{color:#3f3e4c;font-size:14px;font-weight:600}.loader{background-color:#3f4156;border-radius:35px;color:#fff;height:70px;margin:30px auto 70px;max-width:400px;padding:10px}.loader .bar{-webkit-animation:fastphploader 4s ease-in;-webkit-animation-fill-mode:forwards;animation:fastphploader 4s ease-in;animation-fill-mode:forwards;background:#375cf2;background-image:linear-gradient(90deg,#375cf2 0,#994fe2);border-radius:25px;width:20%}.loader .bar,.loader .bar:after{display:block;height:50px;line-height:50px}.loader .bar:after{-webkit-animation:fastphploadertext 4s ease-in;-webkit-animation-fill-mode:forwards;animation:fastphploadertext 4s ease-in;animation-fill-mode:forwards;content:"";font-weight:600;width:100%}footer{background-color:#404058;bottom:0;color:#fff;font-size:12px;height:50px;line-height:30px;padding:10px}footer,footer:before{left:0;position:fixed;right:0}footer:before{background:#375cf2;background-image:linear-gradient(90deg,#375cf2 0,#c14cdb);bottom:50px;content:"";height:5px;width:100%;z-index:-1}footer>span{margin:0 6px}body:after{-webkit-animation:fastphpag 4s ease-in;-webkit-animation-fill-mode:forwards;animation:fastphpag 4s ease-in;animation-fill-mode:forwards;background:url(data:image/jpeg;base64,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AAAAAAAAAAAAAAAAzoAAAAAAAABKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJQAAAAAAAAEUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB//EABQBAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQIQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/EABQBAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQMQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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) 50% no-repeat;content:"";height:100%;position:absolute;width:100%;z-index:-2}@keyframes fastphpag{0%{border-radius:50%;height:0;left:50%;top:50%;width:0}50%{border-radius:25%;height:50%;left:25%;top:25%;width:50%}to{border-radius:0;height:100%;left:0;top:0;width:100%}}@-webkit-keyframes fastphpag{0%{border-radius:50%;height:0;left:50%;top:50%;width:0}50%{border-radius:25%;height:50%;left:25%;top:25%;width:50%}to{border-radius:0;height:100%;left:0;top:0;width:100%}}@keyframes fastphploader{0%{width:20%}to{width:100%}}@-webkit-keyframes fastphploader{0%{width:20%}to{width:100%}}@keyframes fastphploadertext{0%{content:""}99%{content:""}to{content:"Site Açılıyor..."}}@-webkit-keyframes fastphploadertext{0%{content:""}99%{content:""}to{content:"Sayfa Yükleniyor..."}}@-webkit-keyframes fastzid{0%{-webkit-animation-timing-function:cubic-bezier(.55,.055,.675,.19);-webkit-transform:scale3d(.1,.1,.1) translate3d(0,-1000px,0);animation-timing-function:cubic-bezier(.55,.055,.675,.19);opacity:0;transform:scale3d(.1,.1,.1) translate3d(0,-1000px,0)}60%{-webkit-animation-timing-function:cubic-bezier(.175,.885,.32,1);-webkit-transform:scale3d(.475,.475,.475) translate3d(0,60px,0);animation-timing-function:cubic-bezier(.175,.885,.32,1);opacity:1;transform:scale3d(.475,.475,.475) translate3d(0,60px,0)}}@keyframes fastzid{0%{-webkit-animation-timing-function:cubic-bezier(.55,.055,.675,.19);-webkit-transform:scale3d(.1,.1,.1) translate3d(0,-1000px,0);animation-timing-function:cubic-bezier(.55,.055,.675,.19);opacity:0;transform:scale3d(.1,.1,.1) translate3d(0,-1000px,0)}60%{-webkit-animation-timing-function:cubic-bezier(.175,.885,.32,1);-webkit-transform:scale3d(.475,.475,.475) translate3d(0,60px,0);animation-timing-function:cubic-bezier(.175,.885,.32,1);opacity:1;transform:scale3d(.475,.475,.475) translate3d(0,60px,0)}}@media only screen and (max-width:600px){body{padding:0 10px}header img,header svg{margin:20px auto}main h1{font-size:22px}footer{font-size:12px;height:50px;line-height:20px;padding:4px}footer>span:first-child{display:block;height:0;overflow:hidden;width:0}}@media only screen and (max-height:600px){body{padding:0 5px}header img,header svg{margin:10px auto}main h1{font-size:18px}main p{font-size:12px}.loader{margin:10px auto 70px}}.iuam{display:none;opacity:0}</style>
	<style type="text/css" media="screen">
	.loader {
	border: 8px solid #f3f3f3; /* Light grey */
	border-top: 8px solid #3498db; /* Blue */
	border-radius: 50%;
	width: 75px;
	height: 75px;
	animation: spin 2s linear infinite;
	}
	
	@keyframes spin {
	0% { transform: rotate(0deg); }
	50% { transform: rotate(360deg); }
	}
	</style>

	]]
	
local anti_ddos_html_output = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="]] .. default_charset .. [[" />
<meta http-equiv="Content-Type" content="text/html; charset=]] .. default_charset .. [[" />
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
<meta name="robots" content="noindex, nofollow" />
<title>]] .. title .. [[</title>
<style type="text/css">
]] .. style_sheet .. [[
</style>
]] .. head_ad_slot .. [[
]] .. javascript_anti_ddos .. [[
</head>
<br>
	<main>
		<h2>Please wait a moment while we verify your request</h2>
		<p>Your browser will be redirected to the content you want in a short time.</p>
		<p>Please wait about 5 seconds ...</p>
	</main>
<center>
	<div class="loader">
		<span class="loader"></span>
	</div>
]] .. request_details .. [[
</center>
</div>
]] .. ddos_powered_by .. [[
</body>
</html>
]]

--All previous checks failed and no access_granted permited so display authentication check page.
--Output Anti-DDoS Authentication Page
if set_cookies == nil then
set_cookies = challenge.."="..answer.."; path=/; expires=" .. ngx.cookie_time(currenttime+expire_time) .. "; Max-Age=" .. expire_time .. ";" --apply our uid cookie in header here incase browsers javascript can't set cookies due to permissions.
end
ngx.header["Set-Cookie"] = set_cookies
ngx.header["X-Content-Type-Options"] = "nosniff"
ngx.header["X-Frame-Options"] = "SAMEORIGIN"
ngx.header["Cache-Control"] = "public, max-age=0 no-store, no-cache, must-revalidate, post-check=0, pre-check=0"
ngx.header["Pragma"] = "no-cache"
ngx.header["Expires"] = "0"
if powered_by == 1 then
ngx.header["X-Powered-By"] = "PegaFlare | www.pegaflare.com"
end
ngx.header.content_type = "text/html; charset=" .. default_charset
ngx.status = authentication_page_status_output
ngx.say(anti_ddos_html_output)
ngx.exit(ngx.HTTP_OK)