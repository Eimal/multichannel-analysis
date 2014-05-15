%feature('DefaultCharacterSet','UTF8');
if isunix == 1
	cd(strrep(userpath, ':', ''));
end
if ispc == 1
	cd(strrep(userpath, ';', ''));
end
clear all;
