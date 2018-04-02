
clc;

%TEST: imagen con mas de una pelotita en cancha, INVALIDA!
test_number = 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_2_balls.tif', 'SINGLES', 'LEFT', 'SHOT');
    assert(false, 'TEST %d FAIL!', TEST_number);
catch ME
    fprintf('%s\n', ME.message);
    fprintf('TEST %d PASSED!\n', test_number);
end

%TEST: imagen con una cancha que la falta una línea central, INVALIDA!
test_number = test_number + 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_invalid_court_01.tif', 'SINGLES', 'LEFT', 'SHOT');
    [~, R] = imhawkeye('imgs_testing/tennis_court_invalid_court_02.tif', 'SINGLES', 'LEFT', 'SHOT');
    assert(false, 'TEST %d FAIL!', test_number);
catch ME
    fprintf('%s\n', ME.message);
    fprintf('TEST %d PASSED!\n', test_number);
end

%TEST: imagen con un tamaño diferente al esperado, INVALIDA!
test_number = test_number + 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_invalid_image_size.tif', 'SINGLES', 'LEFT', 'SHOT');
    assert(false, 'TEST %d FAIL!', test_number);
catch ME
    fprintf('%s\n', ME.message);
    fprintf('TEST %d PASSED!\n', test_number);
end

%TEST: imagen sin ninguna pelotita, OUT independientemente del resto de los
%parametros.
test_number = test_number + 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_no_ball.tif', 'SINGLES', 'LEFT', 'SHOT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    [~, R] = imhawkeye('imgs_testing/tennis_court_no_ball.tif', 'SINGLES', 'LEFT', 'SERVICE', 'LEFT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    [~, R] = imhawkeye('imgs_testing/tennis_court_no_ball.tif', 'DOUBLES', 'RIGHT', 'SHOT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    [~, R] = imhawkeye('imgs_testing/tennis_court_no_ball.tif', 'DOUBLES', 'RIGHT', 'SERVICE', 'RIGHT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    fprintf('TEST %d PASSED!\n', test_number);
catch ME
    fprintf('%s\n', ME.message);
    assert(false, sprintf('TEST %d FAIL!', test_number));
end

%TEST: imagen válida, sin tocar ninguna línea
test_number = test_number + 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'SINGLES', 'LEFT', 'SHOT');
    assert(strcmp(R, 'IN'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'IN', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'SINGLES', 'RIGHT', 'SHOT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'DOUBLES', 'LEFT', 'SHOT');
    assert(strcmp(R, 'IN'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'IN', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'DOUBLES', 'RIGHT', 'SHOT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'SINGLES', 'LEFT', 'SERVICE', 'LEFT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'SINGLES', 'LEFT', 'SERVICE', 'RIGHT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'SINGLES', 'RIGHT', 'SERVICE', 'LEFT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'SINGLES', 'RIGHT', 'SERVICE', 'RIGHT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'DOUBLES', 'LEFT', 'SERVICE', 'LEFT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'DOUBLES', 'LEFT', 'SERVICE', 'RIGHT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'DOUBLES', 'RIGHT', 'SERVICE', 'LEFT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_001.tif', 'DOUBLES', 'RIGHT', 'SERVICE', 'RIGHT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
    
    fprintf('TEST %d PASSED!\n', test_number);
catch ME
    fprintf('%s\n', ME.message);
    assert(false, 'TEST %d FAIL!', test_number);
end

%TEST: saque válido la pelotita apenas toca una de las líneas que forman el
%área de saque válido
test_number = test_number + 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_002.tif', 'DOUBLES', 'LEFT', 'SERVICE', 'LEFT');
    assert(strcmp(R, 'IN'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'IN', R);
catch ME
    fprintf('%s\n', ME.message);
    assert(false, sprintf('TEST %d FAIL!', test_number));
end

%TEST: saque inválido la pelotita apenas esta por fuera del área de saque
%válido
test_number = test_number + 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_003.tif', 'DOUBLES', 'LEFT', 'SERVICE', 'LEFT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
catch ME
    fprintf('%s\n', ME.message);
    assert(false, sprintf('TEST %d FAIL!', test_number));
end

%TEST: pelotita que toca una de las líneas de fondo pero solo es válido si
%el partido es de dobles
test_number = test_number + 1;
try
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_004.tif', 'DOUBLES', 'RIGHT', 'SHOT');
    assert(strcmp(R, 'IN'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'IN', R);
    
    [~, R] = imhawkeye('imgs_testing/tennis_court_shot_004.tif', 'SINGLES', 'RIGHT', 'SHOT');
    assert(strcmp(R, 'OUT'), 'TEST %d FAIL! Expected: %s Actual: %s', test_number, 'OUT', R);
catch ME
    fprintf('%s\n', ME.message);
    assert(false, sprintf('TEST %d FAIL!', test_number));
end