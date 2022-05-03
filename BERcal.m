function res = BERcal(arr1,arr2)
    res = zeros(size(arr1,1),size(arr1,2));
    for i = 1:size(arr1,1)
        for j = 1:size(arr1,2)
            res(i,j) = 1 - sum(squeeze(arr1(i,j,:))' == arr2)/size(arr1,3);
        end
    end
end