%general settings
fs = 1024;
N = fs * 3.5;

%generate channel frequency and time neighbors 
vfTarget =                  [20, 40, 60];   %target frequencies
vfNeighbF=                  [30, 50, 70];   %neighboring frequencies
nFreqs =                    numel(vfTarget);
nWaveCycles =               11;
nTNeighbSpacingInBursts=    1 + 2/nWaveCycles;
bTNeighbRelativeSpacing =   true;
nPacketSpacinginBursts =    1/nWaveCycles;
nPackets =                  2;
nPreSpaceS =                0.25;

nLongestBurstlen =  round(nWaveCycles * fs / min([vfTarget vfNeighbF]));
nPacketSpacing =    round(nPacketSpacinginBursts * nLongestBurstlen);
nPacketLen =        round(nLongestBurstlen * (2 + nTNeighbSpacingInBursts - 1));

xTrg = zeros(1,N);  %a place to store the target
xNF = zeros(1,N);   %a place to store the neighbor in frequency
xNT = zeros(1,N);   %a place to store the neighbor in time


for i = 1 : numel(vfTarget)         %for al target frequenc
    nPacketOffset = nPreSpaceS * fs + (i - 1)*(nPacketLen + nPacketSpacing);    %initial offset - useful to place at different time moments packets  
    fTarg =  vfTarget(i);
    fNeigF = vfNeighbF(i);
    nTarg =  round(nWaveCycles * (fs / fTarg));   %length of target samples
    vTarg =  sin(2*pi*fTarg/fs  * (0 : nTarg-1)); %target burst

    vfNeighF = linspace(fNeigF, fTarg, nPackets);   %neighboring frequencies
    if bTNeighbRelativeSpacing %same spacing no matter the frequency
        vfNeighT = linspace(round(nTNeighbSpacingInBursts * nTarg),0, nPackets); %dictated by the lowest frequency
    end

    for p = 1 : nPackets - 1
        fNeigF =    vfNeighF(p);
        nNeigF =    nTarg;    %length of the freq neighbor burst   
        vNeighbF =  sin(2*pi*fNeigF/fs * (0 : nNeigF-1) - pi/1.5);

        nFirstTargSample =  nPacketOffset +  (p - 1) * nFreqs * (nPacketLen + nPacketSpacing) + round((nLongestBurstlen-nTarg ) / 2);
        nFirstNFSample =    nFirstTargSample;
        nFirstNTSample =    nFirstTargSample + round(vfNeighT(p));
        
        xTrg(nFirstTargSample : nFirstTargSample + nTarg -  1) = vTarg; 
        xNF (nFirstNFSample   : nFirstNFSample +   nNeigF - 1) = vNeighbF;
        xNT (nFirstNTSample   : nFirstNTSample  +  nTarg -  1) = vTarg;
    end
end

xSignal = xTrg + xNF + xNT;

fois    = 10:0.5:80;
srord   = [5, 10];
time    = linspace(0, N, numel(xSignal)) / 1000 - nPreSpaceS * fs / 1000;

figure;
subplot(1, 2, 1);
slt3 = faslt(xSignal, fs, fois, 3, srord, 0);
imagesc(time, fois, slt3);
set(gca, 'ydir', 'normal');
colormap jet;
% 
subplot(1, 2, 2);
slt5 = faslt(xSignal, fs, fois, 9, srord, 0);
imagesc(time, fois, slt5);
set(gca, 'ydir', 'normal');
colormap jet;

slt20 = slt3(find(fois == 20), :);
slt40 = slt3(find(fois == 40), :);
slt60 = slt3(find(fois == 60), :);

figure;
hold on;
plot(time, slt20);
plot(time, slt40);
plot(time, slt60);
line([time(1), time(end)], [0.5, 0.5], 'color', 'black');

