%feature('DefaultCharacterSet','UTF8');
com.mathworks.mlwidgets.html.HtmlComponentFactory.setDefaultType('HTMLRENDERER');
if isunix == 1
	cd(strrep(userpath, ':', ''));
end
if ispc == 1
	cd(strrep(userpath, ';', ''));
end
clear all;
