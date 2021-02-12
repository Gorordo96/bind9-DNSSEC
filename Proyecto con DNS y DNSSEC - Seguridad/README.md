# Consideraciones iniciales

Este repositorio consiste en una implementacion adicional de "Proyecto con DNS y DNSSEC" con la finalidad de implementar dentro de la red dockerizada dos nuevos contenedores
simulando de alguna manera dos nuevos usuarios. Ambos tienen la posibilidad de realizar consultas legitimas al DNS configurado dentro de la red LAN (192.168.40.40) pero uno de ellos
tambien tiene la posibilidad de realizar ataques Man in the middle. El objetivo es observar como con la implementacion de DNSSEC, el usuario final es capaz de darse cuenta de que sus paquetes
estan siendo manipulados y modificados por un intermediario.

![arquitectura_Red_Pruebas_Seguridad](https://github.com/Gorordo96/bind9-DNSSEC/blob/UsuariosyAtaque/img/Red_ataque.png?raw=true)

# Pasos para realizar pruebas

1. Dar de alta el proyecto mediante el siguiente comando: 

~~~
docker-compose up -d
~~~

2. Listar la cantidad de contenedores:

~~~
docker ps
~~~

3. Ingresar dentro del contendor de bind9:

~~~
docker exec -i -t <id_contenedorbind9> /bin/bash
~~~

4. Levantar el servicio bind9 dentro del contenedor:

~~~
service bind9 start
~~~

5. Salir del contenedor de bind9 e ingresar al del atacante:

~~~
docker exec -i -t <id_contenedorAtacante> /bin/bash
~~~

6. Al listar los archivos y directorios deberia observar por lo menos dos archivos python: "ARP_Spoof.py" y "DNS_Spoof.py"

7. Asegurarse de tener los permisos adecuados sobre los archivos:

~~~
chmod 755 ARP_Spoof.py

chmod 755 DNS_Spoof.py
~~~

8. Ejecutar el ataque ARP Spoofing para funcionar como intermediario entre el servidor DNS y el usuario de las consultas:
~~~
python ARP_Spoof.py &
~~~
9. Comenzaran a imprimirse un monton de lineas, pero sobre la misma consola y mientras se imprime todo por pantalla ejecutar el siguiente comando:
~~~
python DNS_Spoof.py
~~~
10. Hasta aqui tendriamos el ataque activado. Podriamos proseguir con los pasos para las consultas al servidor DNS mediante el usuario pero antes aclararemos como finalizar el ataque.

## Nota
No cierre la consola del atacante.
1. Para finalizar el ataque, sobre la consola donde tiene ejecutando el contenedor del atacante presionar Ctrl + C para finalizar el script "DNS_Spoof.py".
2. quedara corriendo en segundo plano el script "ARP_Spoof.py" por lo tanto ejecute:
~~~
jobs
~~~
deberia salir un numero identificador del proceso y el propio proceso.
3. Utilice ese numero para traer el proceso a primer plano. Ejecute:
~~~
fg %<N_process>
~~~
4. Una vez en primer plano presione Ctrl + C. 

Fin de Nota: Ataque totalmente finalizado.

11. Volviendo a los pasos anteriores.En otra consola, ingrese al contenedor del usuario:
~~~
docker exec -i -t <id_contenedorUsuario> /bin/bash
~~~

12. Realice consultas al servidor DNS de nuestra red lan para obtener informacion sobre nuestros dominios:
~~~
dig @192.168.40.40 paginaweb.trabajoredes2020.com. +dnssec

dig @192.168.40.40 documentacion.trabajoredes2020.com. +dnssec
~~~
13. Verifique el resultado de la consulta tanto como la propia consola del atacante

14. Frene el ataque como se especifica en las Notas y realice nuevamente las consultas

# Referencia para Script del atacante

* https://www.thepythoncode.com/code/make-dns-spoof-python

* https://www.thepythoncode.com/article/building-arp-spoofer-using-scapy

