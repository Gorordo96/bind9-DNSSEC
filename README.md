# Esquema basico

![Esquema_Red](https://github.com/Gorordo96/bind9-DNSSEC/blob/main/img/Esquema%20de%20red.png?raw=true)

# Aclaraciones de la implementacion

Luego de clonar el repositorio debera decidir cual de los proyectos pondra en funcionamiento.

* Proxy inverso con Traefik, Servicio web con Nginx y Servicio de resolucion de nombres DNS (**Proyecto con DNS**)
* Proxy inverso con Traefik, Servicio web con Nginx y Servicio de resolucion de nombres DNS implementando DNSSEC. (**Proyecto con DNSSEC**) 

Ambos proyectos estaran utilizando muchas configuraciones similares, por ende, es necesario realizar una limpieza de contenedores, redes y volumenes antes de migrar de la utilizacion de un proyecto a otro.

En el caso de no contar con ningun otro contenedor, volumen, red e imagen adicionales a las que se especifican en este proyecto puede ejecutar el siguiente comando para generar una limpieza 

~~~
docker system prune -a
~~~

Atencion: Si ya maneja docker y tiene implementado otros servicios, no se recomienda la ejecucion de dicho comando. Elimine muy a conciencia cada contenedor, red, volumen y demas.

Recomendacion: Si solo quiere verificar la utilizacion e implementacion de DNSSEC, se recomienda implementar directamente (**Proyecto con DNSSEC**).

## Pasos

En ambos casos, el primer paso es ubicarse dentro del repositorio del proyecto elegido. Luego, al ejecutar el comando "ls" debera observar 2 carpetas (bind9 y nginx) y un archivo definido como "docker-compose.yml". Si esto es correcto, debera ejecutar posteriormente el comando: 

~~~
docker-compose up -d --build

docker ps
~~~
Estos comandos permitiran levantar todos los servicios, configurarlos y dejarlos listos para interactuar. El ultimo comando, "docker ps" muestra los id (identificadores) de los contenedores en ejecucion (servicios) para que en un futuro se pueda acceder a cada uno de ellos.

~~~

docker exec -i -t <id contenedor> /bin/bash

~~~
En esta instancia es necesario aclarar que si se eligio el proyecto con DNSSEC y se quiere verificar que en verdad funciona, debera seguir los siguientes pasos adicionales dentro del contenedor de bind9.

1. Ingresar al contenedor bind9
2. ejecutar: service bind9 start
3. ejecutar: nano /zones/trabajoredes2020.com-db
4. modificar el serial (incrementarlo) para que la firma en linea configurada en bind9 tenga efecto. Luego, cerrar el archivo
5. ejecutar: service bind9 restart
6. ejecutar: rndc reconfig
7. ejecutar ls /etc/bind/zones/
8. deberia observar los archivos de zona: trabajoredes2020.com-db y 192.168.40-db y tres/cuatro archivos nuevos, donde uno de ellos corresponde a la zona firmada.
9. ejecutar: rndc zonestatus trabajoredes2020.com
10. ejecutar: rndc signing -list trabajoredes2020.com
11. En los resultas de los comandos anteriores, deberia poder verificarse que la zona fue firmada en linea y es segura.
12. Comprobar las resoluciones: dig @192.168.40.40 trabajoredes2020.com. NS +dnssec
13. Comprobar las resoluciones: dig @192.168.40.40 trabajoredes2020.com. SOA +dnssec
14. verificar con un anclaje de confianza.
15. dentro del contenedor de bind9, se ha creado en la raiz un directorio respaldoKeys que contiene un archivo definido como key, con los datos de la KSK publica. Este archivo en su interior, debe tener el siguiente formato:

~~~
trusted-keys {
trabajoredes2020.com. 257 3 5 "AQPWA4BRyjB3eqYNy/oykeGcSXjl+HQK9CciAxJfMcS1vEuwz9c
+QG7s EJnQuH5B9i5o/ja+DVitY3jpXNa12mEn";
};
~~~
* Definir la instancia trusted-keys {};
* Dentro, especificar el dominio sobre el que se posee autoridad y la clave KSK publica de la siguiente manera: trabajoredes2020.com. 257 3 5 "< KSK_publica >";

16. Guardamos el archivo y ejecutamos el siguiente comando: delv @192.168.40.40 -a /respaldoKeys/key +root=trabajoredes2020.com. paginaweb.trabajoredes2020.com.


# Referencia de configuracion de bind con DNSSEC

https://nsrc.org/activities/agendas/en/dnssec-3-days/dns/materials/labs/en/dnssec-bind-inline-signing-howto.html
