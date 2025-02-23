for i = 10:10:200
    fprintf('Current PRF: %d\n', i);
    RadarTx(i)
    pause(1)
end