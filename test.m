brickObj = EV3();
brickObj.connect('usb');
brickObj.motorD.brakeMode = 'Brake';
brickObj.motorD.limitValue = 180;
brickObj.motorD.limitMode = 'Tacho';
brickObj.motorD.power=50;
brickObj.motorD
brickObj.motorD.start();
