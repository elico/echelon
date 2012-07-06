echelon
===========
originaly from:
https://github.com/gen0cide-/echelon

i saw this nice server and modified it to be more easy to use but still not everything tested.

the seturl works 100%

but the addheader and setheader are not fully tested yet.

still havn't got the time to look on the resmod method yet so it just for requests.

will be added option for some db this or another.

will be added the option to use an advaced request and response urls to match crytiria and apply different actions.

problem that are known:
the OPTIONS icap response is not fullty built so squid will show some warnings.

When you are ready, simply `ruby echelon.rb config/settings.yml`
or to backgroud\deamonize `ruby echelon.rb config/settings.yml&`

added
--
i changed the headers manipulation methods and added nice one set302 to allow redirecting filtered requests to specific page.

added the cache module for vimeo,ytimg,youtube.

the youtube cache is not tested yet but the code suppose to work.

added filtering class that has two methods to match blacklists domains of squidguard\danshguardian from a mysql db.
the checks are done on reverse strings of the domains.

use "load data infile'/location/blacklists/porn/domains' into table filter (@var1) set dom= reverse(@var1);" to load the blacklist into mysql.

TODO
==
Add acl to use client ip and user to allow\deny\redirect requests as an acl server for work places.
