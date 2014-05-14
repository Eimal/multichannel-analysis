%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Check for specific MATLAB products %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [product_status] = ver_product(matlab_product_in_question)
matlab = ver;
i = 1;
while i <= length(matlab)
    matlab_products_installed(i) = {matlab(i).Name};
    i = i +1;
end
product_status_cells = regexp(matlab_products_installed,matlab_product_in_question);
product_status = cell2mat(product_status_cells);