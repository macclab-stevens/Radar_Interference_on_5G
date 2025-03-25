for i = 5:5:505

    fprintf('Current PRF: %d\n', i);
    RadarTx(i)
    pause(1)
end