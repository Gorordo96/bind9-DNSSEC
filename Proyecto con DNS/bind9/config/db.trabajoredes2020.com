;
; BIND data file for local loopback interface
;
;
;Configuracion de la base de datos de bind para resolver nombres
;
;
$TTL	604800
@	IN	SOA	trabajoredes2020.com. magajesluc.trabajoredes2020.com. (
			      3		; Serial - recordar que por cada cambio en este archivo hay que incrementarlo
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
; Registros NS
@	IN	NS	trabajoredes2020.com.
;
; Registro A para NS declarado
;
@	IN	A	192.168.40.40
;
;Registro A para servidores web
;
paginaweb	IN	A	192.168.40.30
;
documentacion	IN	CNAME	paginaweb.trabajoredes2020.com.
;
;

