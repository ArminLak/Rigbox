function p = paths(rig)
%DAT.PATHS Returns struct containing important paths
%   p = DAT.PATHS([RIG]) Returns a struct of paths that are used by Rigbox
%   to determine the location of config and experiment files.  The rig
%   input is used to generate rig specific paths, including custom paths.
%   The default is the hostname of this computer.
%
%   The main and local repositories are essential for determining where to
%   save experimental data.
%
% Part of Rigbox

% 2013-03 CB created
% 2019-11 PZH updated for Lak Lab

thishost = hostname;

if nargin < 1 || isempty(rig)
  rig = thishost;
end

server1Name = '\\QNAP-AL001.dpag.ox.ac.uk';

%% Essential paths
% Path containing rigbox config folders
p.rigbox = fileparts(which('addRigboxPaths'));
% Repository for local copy of everything generated on this rig.
% Automatically assign to largest hard disk
drives = double('C'):double('Z');
disk_size = nan(size(drives));
for i = 1:length(drives)
    drive = ['' drives(i) ':\'];
    if exist(drive, 'dir') == 7
        FileObj = java.io.File(drive);
        disk_size(i) = FileObj.getTotalSpace;
    end
end
[~,idx]=max(disk_size);
p.localRepository = ['' drives(idx) ':\LocalExpData'];

% Data are grouped by mouse name within the data directory
p.mainRepository = fullfile(server1Name, 'Data');

% Directory for organisation-wide configuration files
p.globalConfig = fullfile(server1Name, 'Code', 'RigConfig');
% Directory for rig-specific configuration files
p.rigConfig = fullfile(p.globalConfig, rig);
% Repository for all experiment definitions
p.expDefinitions = fullfile(server1Name, 'Code', 'ExpDefinitions');

%% Non-essential paths
% Location of git for automatic updates
p.gitExe = 'C:\Program Files\Git\cmd\git.exe'; 
% Day on which to update code (0 = Everyday, 1 = Sunday, etc.)
p.updateSchedule = 0;


%% user-defined repositories
% The following paths are not used in the main Rigbox code, however may be
% added to this file when using the +dat package for one's own analysis.
% Some examples below:

% Repository for working analyses that are not meant to be stored
% permanently
% p.workingAnalysisRepository = fullfile(basketName, 'data');
% For tape backups, first files go here:
% p.tapeStagingRepository = fullfile(lugaroName, 'bigdrive', 'staging'); 
% Then they go here:
% p.tapeArchiveRepository = fullfile(lugaroName, 'bigdrive', 'toarchive');


end