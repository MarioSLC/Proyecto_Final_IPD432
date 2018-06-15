function y = my_dec2bin64( x )
%MY_DEC2BIN64 Summary of this function goes here
%   Detailed explanation goes here

    if (x < 0)
        y = int2bin(uint64(2^64) - uint64(-x) + 1, 64);
    else
        y = int2bin(uint64(x),64);
    end
end
