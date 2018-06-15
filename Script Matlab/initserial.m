function ser = initserial(COM)
    delete(instrfindall);
    clc
    ser = serial(COM,'BaudRate',115200,'DataBits',8,'StopBits',1, 'FlowControl', 'hardware');
    ser.OutputBufferSize = 6000;
    ser.InputBufferSize = 6000;
    fopen(ser);
end