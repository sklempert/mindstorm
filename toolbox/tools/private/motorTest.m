function ret = motorTest(EV3, mode)
ret = 0;
%Start test
disp(sprintf(['--------------------------------------------------------------\nStart motor test ', mode]));
%Test motor A
EV3.motorA.power=20;
EV3.motorA.limitValue=1000;
try EV3.motorA.start
catch all
end;

answerA = input('Did motor A move? [y/n]', 's');
if ~strcmp(answerA,'y') && ~strcmp(answerA,'n')
    while true
        answerA = input('Incorrect input. Did motor A move? [y/n]', 's');
        if strcmp(answerA,'y') || strcmp(answerA,'n')
            break;
        end
    end
end
%Test motor B
EV3.motorB.power=20;
EV3.motorB.limitValue=1000;
try EV3.motorB.start
catch all
end;

answerB = input('Did motor B move? [y/n]', 's');
if ~strcmp(answerB,'y') && ~strcmp(answerB,'n')
    while true
        answerB = input('Incorrect input. Did motor B move? [y/n]', 's');
        if strcmp(answerB,'y') || strcmp(answerB,'n')
            break;
        end
    end
end

%Test motor C
EV3.motorC.power=20;
EV3.motorC.limitValue=1000;
try EV3.motorC.start
catch all
end;

answerC = input('Did motor C move? [y/n]', 's');
if ~strcmp(answerC,'y') && ~strcmp(answerC,'n')
    while true
        answerC = input('Incorrect input. Did motor C move? [y/n]', 's');
        if strcmp(answerC,'y') || strcmp(answerC,'n')
            break;
        end
    end
end

%Warnings for defect motors
if (~isempty(strfind(answerA, 'n')))
    warning('Test for motor A failed');
end;

if (~isempty(strfind(answerB, 'n')))
    warning('Test for motor B failed');
end;

if (~isempty(strfind(answerC, 'n')))
    warning('Test for motor C failed');
end;

if (~isempty(strfind(answerA, 'y'))) && (~isempty(strfind(answerB, 'y'))) && (~isempty(strfind(answerC, 'y')))
    disp(sprintf('All motors work correctly.\n'));
    ret = 1;
end;

end

