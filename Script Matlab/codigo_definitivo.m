clear
clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%PARAMETROS DEL MOTOR EDITABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VDC = 540;
Lr = 0.13682;
Ls = 0.13682;
Lm = 0.13069;
Rr = 1.2134;
Rs = 1.6647;
p = 2;
J = 0.023981381179640*1*10;%*50;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%PARAMETROS DEL SIMULADOR NO EDITABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NDIV = 15;
CLOCK = 50e6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%VARIABLES DEPENDIENTES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = NDIV/(CLOCK);
t = 0:h:0.3;
sigma = 1 - Lm*Lm/(Ls*Lr);
L_s = sigma*Ls;
k_r = Lm/Lr;
R_s = Rs + k_r*k_r*Rr;
tau_s = L_s/R_s;
tau_r = Lr/Rr;
bits_frac = 59-13;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%CONSTANTES DE ECUACIONES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%eq1
constantes(1) = 1 - h/tau_s;
constantes(2) = h*k_r/(L_s*tau_r);
constantes(3) = h*k_r/L_s;
constantes(4) = h/L_s;

%eq2
constantes(5) = 1 - h/tau_s;
constantes(6) = - h*k_r/L_s;
constantes(7) = h*k_r/(L_s*tau_r);
constantes(8) = h/L_s;

%eq3
constantes(9) = h*Lm/tau_r;
constantes(10) = 1-h/tau_r;
constantes(11) = -h;

%eq4
constantes(12) = h*Lm/tau_r;
constantes(13) = h;
constantes(14) = 1-h/tau_r;

%eq5
constantes(15) = (h*3*p^2*Lm)/(J*2*Lr);
constantes(16) = -h*p/J;

VDC13 = int64(VDC* (2^bits_frac) * 1/3);
VDC23 = int64(VDC* (2^bits_frac) * 2/3);
VDCS3 = int64(VDC* (2^bits_frac) * 1/sqrt(3));

constantes_int = int64(constantes*2^(bits_frac));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%CONVERSION A STRING BINARIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(constantes)
    constantes_bin{i} = my_dec2bin64(constantes_int(i));
end
constantes_bin{17} = my_dec2bin64(VDC13);
constantes_bin{18} = my_dec2bin64(VDCS3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%FUNCION DE INICIALIZACION DE PUERTO SERIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ser = initserial('COM4');


RUN = bin2dec('1000 0000');
IDLE =  bin2dec('0010 0000');

RECONFIG_MOTOR = bin2dec('0100 0000');
RECONFIG_C1 = RECONFIG_MOTOR + 1;
RECONFIG_C2 = RECONFIG_MOTOR + 2;
RECONFIG_C3 = RECONFIG_MOTOR + 3;
RECONFIG_C4 = RECONFIG_MOTOR + 4;
RECONFIG_C5 = RECONFIG_MOTOR + 5;
RECONFIG_C6 = RECONFIG_MOTOR + 6;
RECONFIG_C7 = RECONFIG_MOTOR + 7;
RECONFIG_C8 = RECONFIG_MOTOR + 8;
RECONFIG_C9 = RECONFIG_MOTOR + 9;
RECONFIG_C10 = RECONFIG_MOTOR + 10;
RECONFIG_C11 = RECONFIG_MOTOR + 11;
RECONFIG_C12 = RECONFIG_MOTOR + 12;
RECONFIG_C13 = RECONFIG_MOTOR + 13;
RECONFIG_C14 = RECONFIG_MOTOR + 14;
RECONFIG_C15 = RECONFIG_MOTOR + 15;
RECONFIG_C16 = RECONFIG_MOTOR + 16;
RECONFIG_VDC13 = RECONFIG_MOTOR + 17;
RECONFIG_VDCS3 = RECONFIG_MOTOR + 18;

fwrite(ser, char(IDLE));

%%%%%%%%%%%%%%%%%%%%%%%%%
% CARGAR CONSTANTES
%%%%%%%%%%%%%%%%%%%%%%%%%
for j = 1:18
    tag_temp = char(RECONFIG_MOTOR + j);
    fwrite(ser,tag_temp);
    constante_temp = constantes_bin{j};    
    for i = 8:-1:1
        fwrite(ser, char(bin2dec(constante_temp((8*(i-1)+1):8*i))));
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%
% CARGAR CONFIGURACION TRIGGER
%%%%%%%%%%%%%%%%%%%%%%%%%
RECONFIG_TRIGGER = (bin2dec('0110 0000'));

TRIGGER_ISA = 0;
TRIGGER_ISB = 1;
TRIGGER_PSIA = 2;
TRIGGER_PSIB = 3;
TRIGGER_WR = 4;

TRIGGER_EQ = 0 * 2^4;  % =
TRIGGER_LEQ = 1 * 2^4; % <=
TRIGGER_LES = 2 * 2^4; % <
TRIGGER_GEQ = 3 * 2^4; % >=
TRIGGER_GRE = 4 * 2^4; % >

fwrite(ser, char(RECONFIG_TRIGGER));
%fwrite(ser, char(TRIGGER_WR + TRIGGER_GEQ));
fwrite(ser, char(TRIGGER_WR + TRIGGER_GEQ));
%trigger_level = 300;
trigger_level = 100;
trigger_level = my_dec2bin64(trigger_level * 2^bits_frac);
for i = 8:-1:1
    fwrite(ser, char(bin2dec(trigger_level((8*(i-1)+1):8*i))));
end

fwrite(ser, char(RUN));


%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%LECTURA CONSTANTE DEL PUERTO SERIAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
temp1 = 0;
temp2 = 0;
contador = 1;
contador_ext = 0;
resultado = [];
finalizado = 0;
todo = [];
while(finalizado ~=1)
    if(ser.BytesAvailable >= 1)
        temp1 = fread(ser,1);
        contador_ext = contador_ext + 1;
        if (temp1 >= 128)
            if(mod(contador, 1000) == 0) 
                disp(contador)
            end
            temp2(1) = temp1;% - 128;
            temp2(2:37) = fread(ser,36);
            todo(contador,:) = temp2;
%             [temp2(end-2) temp2(end-1) temp2(end) (temp2(end-2)*2^14 + temp2(end-1)*2^7+temp2(end))/8];
%             if (temp2(end) < 128 && temp2(end-1) < 128)
%                 resultado(length(resultado)+1) = (temp2(end-2)*2^14 + temp2(end-1)*2^7+temp2(end))/8;
%             end
            contador = contador + 1;
        end
        if (temp2(end) >= 128 && temp2(end-1) >= 128)
            finalizado = 1;
        end        
    end
end


% 2.^(repmat([1 0],4,1))

% el paquete de 256 bits está dividido en
% 1   Bit - Bit 256: Sa
% 1   Bit - Bit 255: Sb
% 1   Bit - Bit 254: Sc
% 42 Bits - Bit 253-212: Isa
% 42 Bits - Bit 211-170: Isb
% 42 Bits - Bit 169-128: Psi_ra
% 42 Bits - Bit 127-86: Psir_rb
% 42 Bits - Bit 85-44: wr
% 42 Bits - Bit 43-2: TL

% Un paquete de 256 bits esta repartido
% en 37 paquetes, en 7 de 8 bits.
% El primer bit es usado para identificar
% el primer paquete.

maximo = length(todo(:,1)) - 1;

corrimiento = -30;
temp2 = 1;
truncar = 0;
close all
clear is_alfa is_beta psir_alfa psir_beta wr

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%CONVERSION DE DATOS RECIBIDOS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:maximo
    Sa(i,1) = bitget(todo(i,1),7);
    Sb(i,1) = bitget(todo(i,1),6);
    Sc(i,1) = bitget(todo(i,1),5);
    
    j = 0;
    temp = [bitget(todo(i,j+1), 4:-1:1), bitget(todo(i,j+2), 7:-1:1)];         %4+7 = 11
    temp = [temp, bitget(todo(i,j+3), 7:-1:1), bitget(todo(i,j+4), 7:-1:1)];   %11 + 7 + 7 = 25
    temp = [temp, bitget(todo(i,j+5), 7:-1:1), bitget(todo(i,j+6), 7:-1:1)];   %25 + 7 + 7 = 39
    temp = [temp, bitget(todo(i,j+7), 7:-1:5)];                                %39 + 3 = 42  
    %temp_var = int64(2.^([41:-1:1]))*int64(temp(2:end))';   
    temp_var = 2.^([41:-1:1])*temp(2:end)';
    is_alfa(i,1) = temp_var;
     if (temp(1) == 1)
         temp_var = -2^(42) + temp_var + 1;
     end   
     is_alfa(i,1) = temp_var*2^corrimiento;
      
    %is_alfa(i,:) = temp;
    
    if(temp2) 
    j = 6;
    temp = [bitget(todo(i,j+1), 4:-1:1), bitget(todo(i,j+2), 7:-1:1)];         %4+7 = 11
    temp = [temp, bitget(todo(i,j+3), 7:-1:1), bitget(todo(i,j+4), 7:-1:1)];   %11 + 7 + 7 = 25
    temp = [temp, bitget(todo(i,j+5), 7:-1:1), bitget(todo(i,j+6), 7:-1:1)];   %25 + 7 + 7 = 39
    temp = [temp, bitget(todo(i,j+7), 7:-1:5)];                                %39 + 3 = 42  
    %is_beta(i,1) = 2.^([42:-1:1])*temp'*2^corrimiento;
    temp_var = 2.^([41:-1:1])*temp(2:end)';
    if (temp(1) == 1)
        temp_var = -2^(42) + temp_var + 1;
    end        
    is_beta(i,1) = temp_var*2^corrimiento;
    
    j = 12;
    temp = [bitget(todo(i,j+1), 4:-1:1), bitget(todo(i,j+2), 7:-1:1)];         %4+7 = 11
    temp = [temp, bitget(todo(i,j+3), 7:-1:1), bitget(todo(i,j+4), 7:-1:1)];   %11 + 7 + 7 = 25
    temp = [temp, bitget(todo(i,j+5), 7:-1:1), bitget(todo(i,j+6), 7:-1:1)];   %25 + 7 + 7 = 39
    temp = [temp, bitget(todo(i,j+7), 7:-1:5)];                                %39 + 3 = 42  
    %psir_alfa(i,1) = 2.^([42:-1:1])*temp'*2^corrimiento;
    temp_var = 2.^([41:-1:1])*temp(2:end)';    
    if (temp(1) == 1)
        temp_var = -2^(42) + temp_var + 1;
    end        
    psir_alfa(i,1) = temp_var*2^corrimiento;
    
    j = 18;
    temp = [bitget(todo(i,j+1), 4:-1:1), bitget(todo(i,j+2), 7:-1:1)];         %4+7 = 11
    temp = [temp, bitget(todo(i,j+3), 7:-1:1), bitget(todo(i,j+4), 7:-1:1)];   %11 + 7 + 7 = 25
    temp = [temp, bitget(todo(i,j+5), 7:-1:1), bitget(todo(i,j+6), 7:-1:1)];   %25 + 7 + 7 = 39
    temp = [temp, bitget(todo(i,j+7), 7:-1:5)];                                %39 + 3 = 42   
    %psir_beta(i,1) = 2.^([42:-1:1])*temp'*2^corrimiento;   
    temp_var = 2.^([41:-1:1])*temp(2:end)';    
    if (temp(1) == 1)
        temp_var = -2^(42) + temp_var + 1;
    end        
    psir_beta(i,1) = temp_var*2^corrimiento;
    
    j = 6*4;
    temp = [bitget(todo(i,j+1), 4:-1:1), bitget(todo(i,j+2), 7:-1:1)];         %4+7 = 11
    temp = [temp, bitget(todo(i,j+3), 7:-1:1), bitget(todo(i,j+4), 7:-1:1)];   %11 + 7 + 7 = 25
    temp = [temp, bitget(todo(i,j+5), 7:-1:1), bitget(todo(i,j+6), 7:-1:1)];   %25 + 7 + 7 = 39
    temp = [temp, bitget(todo(i,j+7), 7:-1:5)];                                %39 + 3 = 42  
    %wr(i,1) = 2.^([42:-1:1])*temp'*2^corrimiento;  
    temp_var = 2.^([41:-1:1])*temp(2:end)';    
    if (temp(1) == 1)
        temp_var = -2^(42) + temp_var + 1;
    end     
    wr(i,1) = temp_var*2^corrimiento;
    
    j = 6*5;
    temp = [bitget(todo(i,j+1), 4:-1:1), bitget(todo(i,j+2), 7:-1:1)];         %4+7 = 11
    temp = [temp, bitget(todo(i,j+3), 7:-1:1), bitget(todo(i,j+4), 7:-1:1)];   %11 + 7 + 7 = 25
    temp = [temp, bitget(todo(i,j+5), 7:-1:1), bitget(todo(i,j+6), 7:-1:1)];   %25 + 7 + 7 = 39
    temp = [temp, bitget(todo(i,j+7), 7:-1:5)];                                %39 + 3 = 42  
    %TL(i,1) = 2.^([42:-1:1])*temp'*2^corrimiento;    
    temp_var = 2.^([41:-1:1])*temp(2:end)';    
    if (temp(1) == 1)
        temp_var = -2^(42) + temp_var + 1;
    end        
    TL(i,1) = temp_var*2^corrimiento;
    end
end   

xwidth = 1300*0.7*0.5*1.5
ywidth = 300*0.7;
imprimir = 1;
tam_letra = 12;
tam_legend = 13;
set(0,'defaultlinelinewidth',1);

close all
a = figure(1);
plot(Sa + 1.1)
hold on
plot(Sb)
plot(Sc - 1.1)
title('Sabc')

if(temp2)
a = figure(2);
plot(is_alfa)
hold on
plot(is_beta)
grid on
box on
set(a,'Position', [100 400 xwidth ywidth],'PaperUnits', 'points','PaperPosition', [0 0 xwidth ywidth]);
set(gca,'fontsize',tam_letra)
xlabel('Dato [-]')
ylabel('Corriente [A]')
legend({'$i_{s\alpha}$','$i_{s\beta}$'},'interpreter','latex','fontsize',tam_letra+5);
if imprimir    
    print(a,'../Informe/img/corrientes','-depsc')
    %print(a,'./img/wg2','-depsc')
end


a = figure(4);
plot(psir_alfa)
hold on
plot(psir_beta)
grid on
box on
set(a,'Position', [100 400 xwidth ywidth],'PaperUnits', 'points','PaperPosition', [0 0 xwidth ywidth]);
set(gca,'fontsize',tam_letra)
xlabel('Dato [-]')
ylabel('Flujo [Wb]')
legend({'$\psi_{r\alpha}$','$\psi_{r\beta}$'},'interpreter','latex','fontsize',tam_letra+5);
if imprimir    
    print(a,'../Informe/img/flujos','-depsc')
    %print(a,'./img/wg2','-depsc')
end

a = figure(6);
plot(wr)
grid on
box on
set(a,'Position', [100 400 xwidth ywidth],'PaperUnits', 'points','PaperPosition', [0 0 xwidth ywidth]);
set(gca,'fontsize',tam_letra)
xlabel('Dato [-]')
ylabel('Velocidad [rad/s]')
ylim([0 120])
if imprimir    
    print(a,'../Informe/img/velocidad','-depsc')
    %print(a,'./img/wg2','-depsc')
end

end
