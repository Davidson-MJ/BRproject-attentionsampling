% getDatanames

%WM LOW vis.Mismatch
Datanames(1).name='allRTdata_AttLowCongruentSwitches.mat';%mismatch
Datanames(1).nameSimple='Crossmodal mismatch';
Datanames(31).name='allRTdata_AttLowCongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat'; %match
Datanames(31).nameSimple='2nd switch Crossmodal Match';
Datanames(51).name='allRTdata_AttLowCongruentSwitches_2ndwinXMOD_alignedtoOnset.mat';
Datanames(51).nameSimple='Low vis.mismatch(ALC), 2nd, Onsetaligned ';
Datanames(61).name= 'allRTdata_AttLowCongruentSwitches_afteroffset.mat';
Datanames(61).nameSimple= 'Attending Low freq cue to switch, after offset';


%WM LOW vis.Match
Datanames(2).name='allRTdata_AttLowIncongruentSwitches.mat'; %peak
Datanames(2).nameSimple='Crossmodal match';
Datanames(32).name='allRTdata_AttLowIncongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(32).nameSimple='2nd switch Crossmodal Mismatch';
Datanames(52).name='allRTdata_AttLowIncongruentSwitches_2ndwinXMOD_alignedtoOnset.mat';
Datanames(52).nameSimple='Low vis.match(ALI), 2nd, Onsetaligned ';
Datanames(62).name= 'allRTdata_AttLowIncongruentSwitches_afteroffset.mat';
Datanames(62).nameSimple= 'Attending Low freq cue to stay, after offset';


%WM HIGH vis.Match
Datanames(3).name='allRTdata_AttHighCongruentSwitches.mat'; %peak
Datanames(3).nameSimple='(20Hz) Nonconscious cue';
Datanames(33).name='allRTdata_AttHighCongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(33).nameSimple='High vis.mismatch(AHC), 2nd, switchaligned ';
Datanames(53).name='allRTdata_AttHighCongruentSwitches_2ndwinXMOD_alignedtoOnset';
Datanames(53).nameSimple='High vis.mismatch(AHC), 2nd, Onsetaligned ';

%WM High vis.Match
Datanames(4).name='allRTdata_AttHighIncongruentSwitches.mat';
Datanames(4).nameSimple='(20Hz) Conscious cue';
Datanames(34).name='allRTdata_AttHighIncongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(34).nameSimple='High vis.match(AHI), 2nd, switchaligned';
Datanames(54).name='allRTdata_AttHighIncongruentSwitches_2ndwinXMOD_alignedtoOnset';
Datanames(54).nameSimple='High vis.match(AHI), 2nd, Onsetaligned ';

%WM High xm.mismatch
Datanames(5).name='allRTdata_nAttLowCongruentSwitches.mat';
Datanames(5).nameSimple='(Ignore 4.5Hz) Nonconscious cue';
Datanames(35).name='allRTdata_nAttLowCongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(35).nameSimple='High xm.mismatch(nALC), 2nd, switchaligned ';
Datanames(55).name='allRTdata_nAttLowCongruentSwitches_2ndwinXMOD_alignedtoOnset.mat';
Datanames(55).nameSimple='High xm.mismatch(nALC), 2nd, Onsetaligned ';


%WM Low xm.Match
Datanames(6).name='allRTdata_nAttLowIncongruentSwitches.mat'; %peak
Datanames(6).nameSimple='(Ignore 4.5Hz) Conscious cue';
Datanames(36).name='allRTdata_nAttLowIncongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat'; %peak
Datanames(36).nameSimple='Low xm.match(nALI), 2nd, switchaligned';
Datanames(56).name='allRTdata_nAttLowIncongruentSwitches_2ndwinXMOD_alignedtoOnset.mat'; %peak
Datanames(56).nameSimple='Low xm.match(nALI), 2nd, Onsetaligned';

%WM Low xm.mismatch
Datanames(7).name='allRTdata_nAttHighCongruentSwitches.mat';
Datanames(7).nameSimple='(Ignore 20Hz) Nonconscious cue';
Datanames(37).name='allRTdata_nAttHighCongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(37).nameSimple='Low xm.mismatch(nAHC), 2nd, switchaligned';
Datanames(57).name='allRTdata_nAttHighCongruentSwitches_2ndwinXMOD_alignedtoOnset.mat';
Datanames(57).nameSimple='Low xm.mismatch(nAHC), 2nd, Onsetaligned';
%

%WM High xm.Match
Datanames(8).name='allRTdata_nAttHighIncongruentSwitches.mat';
Datanames(8).nameSimple='(Ignore 20Hz) Conscious cue';
Datanames(38).name='allRTdata_nAttHighIncongruentSwitches_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(38).nameSimple='High xm.match(nAHI), 2nd, switchaligned';
Datanames(58).name='allRTdata_nAttHighIncongruentSwitches_2ndwinXMOD_alignedtoOnset.mat';
Datanames(58).nameSimple='High xm.match(nAHI), 2nd, Onsetaligned';

%Preonset
Datanames(9).name='allRTdata_PreOnsetDuration.mat';
Datanames(9).nameSimple='All switches pre cue onset';
Datanames(99).name='allRTdata_PostOffsetDuration.mat';
Datanames(99).nameSimple='All post cue-offset';

%%%%%%%%%%%%%%%%%%%%%%%% COMBINED CASES [ 1 2 3 4]
Datanames(111).name='allRTdata_WML_durmismatch.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WML mismatch
% Datanames(111).nameSimple = 'Attending 4.5Hz, crossmodal mismatch';
Datanames(111).nameSimple = 'Crossmodal mismatch';
Datanames(131).name='allRTdata_WML_durmismatch_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(131).nameSimple = 'all WM=low dur mismatch, 2nd, switchaligned (WMH now match)';
Datanames(151).name='allRTdata_WML_durmismatch_2ndwinXMOD_alignedtoOnset.mat';
Datanames(151).nameSimple = 'all WM=low dur mismatch, 2nd, Onsetaligned (WMH now match)';


Datanames(112).name='allRTdata_WML_nomismatch.mat';%%%%%%%%%%%%%%%%%%%%%%%% WML no mismatch
% Datanames(112).nameSimple = 'Attending 4.5Hz, crossmodal match';
Datanames(112).nameSimple = 'Crossmodal match';
Datanames(132).name='allRTdata_WML_nomismatch_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(132).nameSimple = 'all WM=low no mismatch, 2nd, switchaligned (WMH now mismatch)';
Datanames(152).name='allRTdata_WML_nomismatch_2ndwinXMOD_alignedtoOnset.mat';
Datanames(152).nameSimple = 'all WM=low no mismatch, 2nd, Onsetaligned (WMH now mismatch)';

Datanames(113).name='allRTdata_WMH_durmismatch.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH dur mismatch
Datanames(113).nameSimple = 'Attending 20Hz, crossmodal mismatch';
Datanames(133).name='allRTdata_WMH_durmismatch_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(133).nameSimple = '2nd, switchaligned (WML now match)';
Datanames(153).name='allRTdata_WMH_durmismatch_2ndwinXMOD_alignedtoOnset.mat';
Datanames(153).nameSimple = '2nd, Onsetaligned (WML now match)';

Datanames(114).name='allRTdata_WMH_nomismatch.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH no mismatch
Datanames(114).nameSimple = 'Attending 20Hz, crossmodal match';
Datanames(134).name='allRTdata_WMH_nomismatch_2ndwinXMOD_alignedtofirstswitch.mat';
Datanames(134).nameSimple = 'all WM=high no mismatch, 2nd, switchaligned (WML now mismatch)'; %2nd
Datanames(154).name='allRTdata_WMH_nomismatch_2ndwinXMOD_alignedtoOnset.mat';
Datanames(154).nameSimple = 'all WM=high no mismatch, 2nd, Onsetaligned (WML now mismatch)';%2nd Onset (24)



%%% true 2nd switches
Datanames(115).name='allRTdata_WML_TRUE2ndmismatch_2ndwinXMOD_alignedtofirstswitch.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH no mismatch
Datanames(115).nameSimple = '2nd switch Crossmodal Mismatch';

Datanames(116).name='allRTdata_WML_TRUE2ndmismatch_2ndwinXMOD_alignedtoOnset.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH no mismatch
Datanames(116).nameSimple = '2nd switch, now 4.5Hz mismatched';

Datanames(117).name='allRTdata_WML_TRUE2nd_nomismatch_2ndwinXMOD_alignedtofirstswitch.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH no mismatch
Datanames(117).nameSimple = '2nd switch Crossmodal Match';

Datanames(118).name='allRTdata_WML_TRUE2nd_nomismatch_2ndwinXMOD_alignedtoOnset.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH no mismatch
Datanames(118).nameSimple = '2nd switch, now 4.5Hz matched';


Datanames(119).name='allRTdata_WMH_TRUE2nd_nomismatch_2ndwinXMOD_alignedtoOnset.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH no mismatch
Datanames(119).nameSimple = '2nd switch, now 20Hz matched';
Datanames(120).name='allRTdata_WMH_TRUE2ndmismatch_2ndwinXMOD_alignedtoOnset.mat'; %%%%%%%%%%%%%%%%%%%%%%%% WMH no mismatch
Datanames(120).nameSimple = '2nd switch, now 20Hz mismatched';

% NOW USING ALL SWITCHES UNCONDITIONAL (not contained within XMOD). 

Datanames(101).name='allRTdata_AttLowCongruentSwitches_Unconditional';
Datanames(102).name='allRTdata_AttLowIncongruentSwitches_Unconditional';
%
Datanames(103).name='allRTdata_Visonly1stswitch_Unconditional';
%
Datanames(104).name = 'allRTdata_AttHighCongruentSwitches_Unconditional';
Datanames(105).name = 'allRTdata_AttHighIncongruentSwitches_Unconditional';

Datanames(106).name = 'allRTdata_nAttLowCongruentSwitches_Unconditional';
Datanames(107).name = 'allRTdata_nAttLowIncongruentSwitches_Unconditional';

Datanames(108).name = 'allRTdata_nAttHighCongruentSwitches_Unconditional';
Datanames(109).name = 'allRTdata_nAttHighIncongruentSwitches_Unconditional';

%no the nonattend versions
 %Lowhz
    %     plotdatatype = [1 7 2 6]; use 0:2, shows individual vis/xm effects for WML
    %     plotdatatype = [3 4 5 8];% as above but WMH (inconsistent)
    
    %all mismatch, then match = 111, 133;  ('stable' .5-2) median sw +-1/
    %all match, then mismatch = 112, 134; ('stable' .5-2)
    %   131 = 31+37;
    %   132 = 32+36;
    %   133 = 33+35
    %  134 = 34+38
    
    % 115 = 31+35, 'true L 2nd after mismatch' sw aligned
    %116 = 51+55, 'true L 2nd after mismatch' Onset aligned
    
    % 117 = 32+38, 'true L 2nd (after?) match' sw aligned
    % 118 = 52+58, 'true L 2nd after match' onset aligned
    
    %119 =true H 2nd match
    %120 = true H 2nd mismatch
    % %%
% [1 3 5 7] = congruent
% [2 4 6 8] = Incongruent
% [1 2 3 4] = Att
% [5 6 7 8] = nAtt
% [2 3 6 7]= Low->Highswitches
% [1 4 5 8]= High->Lowswitches
%WM low -> mismatch XMODAL (cuesearch)
%[1 7 ] %
%WM high ->nomismatch (nosearch)
%[ 4 8]
