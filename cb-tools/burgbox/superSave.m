function superSave(path, vars, format)
%SUPERSAVE Saves variables to multiple MAT-files and can create folders
%   SUPERSAVE(path, vars, [format]) saves the fields in 'vars' to one or
%   more MAT-files indicated by 'path', which can be a single string or a
%   cell array with multiple paths. If the folders in the paths do not
%   exist, superSave will attempt to create them before saving.
%   Optionally specify a save format flag (e.g. '-v7.3') for variables
%   that may exceed the 2GB per-variable limit of the default MAT-file
%   format; if omitted, MATLAB's default save format is used, preserving
%   prior behaviour.
%
% Part of Burgbox

% 2013-02 CB created

  if nargin < 3
    formatArgs = {};
  else
    formatArgs = {format};
  end

  function saveIndiv(fn)
    pathstr = fileparts(fn);
    % if the containing folder does not exist, create it
    if ~isempty(pathstr) && ~exist(pathstr, 'dir')
      mkdir(pathstr);
    end
    save(fn, '-struct', 'vars', formatArgs{:});
  end

if iscell(path)
  cellfun(@saveIndiv, path);
else
  saveIndiv(path);
end

end
