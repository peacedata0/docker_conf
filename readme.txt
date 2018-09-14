сертификат должен лежать в Trusted Root Certification Authorities
=======================================================================

при первом запуске эта хуёвина будет искать в системе сертификат с айдишкой 
6390bcdcc7e76c98426254ab9608eb71, сама его поставит, и больше трогать не будет
=======================================================================

файл Startup.cs, 101 строчка 
options.Filters.Add(new RequireHttpsAttribute());

в том же файле, в какую-то 50 строчку добавить 
services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

там же в Configure для хедера HTTPS, добавить 

app.Use((context, next) =>
{
    context.Request.Scheme = "https";
    return next();
});
========================================================================
		PORT FORWARDING (TESTING)
========================================================================

firewall-cmd --permanent --zone=external --add-rich-rule='rule family="ipv4"  \
source address="ip/net_of_source_with_prefix" forward-port="3389" \
protocol="tcp" to-port="3389" to-address="<win_ip_with_prefix_or_mask>"'

=========================================================================
		PORT FORWARDING TO SPECIFIG DESTINATION
=========================================================================

source http://www.firewalld.org/documentation/man-pages/firewalld.richlanguage.html

firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" destination address="198.51.100.237" forward-port port="80" protocol="tcp" to-port="8080"'

Once your rich rule is working, remember to make it permanent with

firewall-cmd --runtime-to-permanent

or adding --permanent to the previous invocation.
==========================================================================

Note: I admit I am proposing a weird and possibly unsupported solution, which may get broken 
on future firewalld versions. Nonetheless, it will certainly work on a CentOS 7 server.

I suggest you to directly add such port forwarding rule into the iptables/ip6tables stack. You 
can achieve that by using firewalld's direct rules. For example:

# firewall-cmd --permanent --direct --add-rule ipv4 nat PRE_public_allow 0 \
    --destination 11.22.33.44 --protocol tcp --destination-port 80 \
    --jump REDIRECT --to-ports 8080

# firewall-cmd --permanent --direct --add-rule ipv6 nat PRE_public_allow 0 \
    --destination 11:22:33:44:55:66:77:88 --protocol tcp --destination-port 80 \
    --jump REDIRECT --to-ports 8080
    		
I figured that CentOS's firewalld creates a PRE_<zone>_allow chain in nat table for each active 
zone, which gets evaluated when packets that matches zone definitions arrive. So 
iptables/ip6tables rules can be added there.

==========================================================================