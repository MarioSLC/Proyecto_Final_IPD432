# Proyecto_Final_IPD432


###########################################################################
## 1. Primeros pasos
###########################################################################


###########################################################################
## 1.1 Simulador HIL
###########################################################################
En la carpeta "Motor - Proyecto Final" se encuentra el proyecto de Vivado
que contiene el Simulador HIL implementado en la plataforma Nexys 4 DDR.
Se debe abrir el archivo "Motor.xpr", sintetizar, implementar y cargar el
bitstream en la plataforma.

Una vez cargado el bitstream, todas las constantes del modelo son 
inicializadas en cero. Para cargar los parámetros del motor y configuración
del trigger, se debe correr el script "codigo_definitivo.m" en MATLAB. Una
vez que es cargada la configuración del motor, el script queda a la espera 
de que el motor gatille la condición de trigger y pase a modo DOWN_DATA.

Terminada la transferencia de datos, el script desempaqueta la información
recibida y graficas las variables resultantes.

###########################################################################
## 1.2 Controlador
###########################################################################





###########################################################################
###########################################################################



###########################################################################
## 2. Interfaz y conmutadores
###########################################################################

Hay algunas configuraciones que no son editables desde el puerto UART, sino
desde la interfaz de conmutadores y botones presentes en la tarjeta. En el
caso de los botones, sólamente el boton central contiene una funcionalidad
asignada, la cual corresponde a reiniciar y habilitar el estado de trigger.

El orden de los conmutadores en la tarjeta es:

| SW[15] | SW[14] |.... | SW[1] | SW[0] |

La funcionalidad asignada a cada uno es:

TRIGGER.-	
	SW[12] -> Si se encuentra activo, los conmutadores SW[2:0] establecen 
	un downsampling del muestreo de datos en RAM. Si se encuentra 
	desactivado, no se realiza downsampling y la tasa de muestreo de datos
	es idéntica al paso de tiempo del modelo.
	
	SW[2:0] -> Realiza downsampling del muestreo de datos en RAM, de acuerdo
	a la siguiente tabla:
		000: fs/20
		001: fs/50
		010: fs/200
		011: fs/500
		100: fs/2000
		101: fs/4000
		110: fs/10000
		111: fs/20000	
	donde fs corresponde a la frecuencia de muestreo del modelo. Por ejemplo,
	si la posición es 000, la tasa de captura de datos es veinte veces menor
	que la frecuencia de ejecución del modelo.
	
DISPLAY 7-seg.-
	SW[5:3] -> Selecciona la variable a desplegar en el display de siete
	segmentos de acuerdo a la siguiente tabla:
		000: Is_alfa
		001: Is_beta
		010: Psir_alfa
		011: Psir_beta
		100: wr
		eoc: 0 (valor constante)
	SW[15] -> Habilita el despliegue continuo o congela la lectura actual.
	
OTROS.-
	SW[14] -> Reinicia las variables de estado del motor a cero.
	SW[11] -> Conmuta entre la referencia interna, y la referencia externa
		      escrita en el puerto JA[2:0].
	SW[13] -> Activa o desactiva los pulsos de la referencia interna.
	
El resto de los conmutadores no posee funcionalidad alguna.
	
###########################################################################
###########################################################################

###########################################################################
## 3. Estructura Proyecto Simulador HIL
###########################################################################

La estructura del proyecto de Vivado del simulador HIL corresponde a:

Motor (Modulo main)
|
|
|
+--- deb (Debouncer del boton BC)
|
|
|
+--- uart_basic_inst (Controlador básico del puerto uart)
|	  |
|     |
|     |
|     +--- baud8_tick_blk (Baud Clock de uart_rx_blk)
|	  |
|     |
|     |
|     +--- uart_rx_blk (Modulo de recepción de datos uart)
|	  |
|     |
|     |
|     +--- baud_tick_blk (Baud Clock de uart_tx_blk)
|	  |
|     |
|     |
|     +--- uart_tx_blk (Modulo de transmisión de datos uart)
|
|
|
+--- Command_Decoder (Módulo que decodifica los paquetes UART y reconfigura
|					  los parámetros y constantes del motor y trigger. También
|					  se encarga de descargar los datos de trigger al PC por
|					  medio de la UART)
|
|
|
+--- motor_core (Núcleo central que implementa el modelo del motor de inducción)
|     |
|     |
|     |
|     +--- convertidor (Implementa el modelo ideal del convertidor)
|     |
|     |
|     |
|     +--- eq_1 (Ecuación de estado de Is_alfa)
|     |
|     |
|     |
|     +--- eq_2 (Ecuación de estado de Is_beta)
|     |
|     |
|     |
|     +--- eq_3 (Ecuación de estado de Psir_alfa)
|     |
|     |
|     |
|     +--- eq_4 (Ecuación de estado de Psir_beta)
|     |
|     |
|     |
|     +--- eq_5 (Ecuación de estado de wr)
|     
|     
|     
+--- bin_to_decimal (Conversor de binario a codificacion decimal)
|
|
|
+--- seg7decimal (Conversor de codificacion decimal a siete segmentos)
|
|
|
+--- Trigger_Control (Módulo que implementa la lógica de trigger e intermedia
|	  |				  la transferencia de datos entre el núcleo del motor y el
|	  |				  controlador de la memoria RAM)
|     |
|	  +--- Controlador_RAM (Instancia la interfaz MIG y la máquina de estados
|	  	    |		        requerida para el control de la memoria RAM)
|           |
|           |
|           +--- clock_mig (Genera el clock requerido por MIG)
|           |
|           |
|           |
|           +--- mig_7series_0 (Instancia la IP de interfaz de memoria MIG)
|			|
|           |
|           |
|           +--- FSM_Controlador_RAM (Máquina de estados para el control de 
|									  memoria RAM)
|
|
+---- Modulador_PWM1 (Modulador de Is_alfa)				  
|
|
|
+---- Modulador_PWM2 (Modulador de Is_beta)
|
|
|
+---- Modulador_PWM3 (Modulador de wr)


###########################################################################
###########################################################################