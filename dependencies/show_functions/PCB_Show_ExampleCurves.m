% example curves

% colors
LL = [11 48 65]/255;
LM = [52 111 31]/255;
LH = [85 184 50]/255;
ML = [21 96 130]/255;
MM = [0 153 153]/255;
MH = [66 218 131]/255;
HL = [15 158 213]/255;
HM = [78 203 224]/255;
HH = [0 255 255]/255;

figure(1)
PCB_Show_SimpleCurve([0.5,0.5,0.85,0.6],LL);
figure(2)
PCB_Show_SimpleCurve([0.5,10,0.85,0.6],LM);
figure(3)
PCB_Show_SimpleCurve([0.5,25,0.85,0.6],LH);
figure(4)
PCB_Show_SimpleCurve([10,0.5,0.85,0.6],ML);
figure(5)
PCB_Show_SimpleCurve([10,10,0.85,0.6],MM);
figure(6)
PCB_Show_SimpleCurve([10,25,0.85,0.6],MH);
figure(7)
PCB_Show_SimpleCurve([25,0.5,0.85,0.6],HL);
figure(8)
PCB_Show_SimpleCurve([25,10,0.85,0.6],HM);
figure(9)
PCB_Show_SimpleCurve([25,25,0.85,0.6],HH);

