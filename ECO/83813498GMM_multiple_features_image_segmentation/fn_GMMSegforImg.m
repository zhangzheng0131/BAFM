function [I_segm, I_posterior, I_max_posterior, ll] = fn_GMMSegforImg(img_feature_array, C, max_iteration, Rep)

% Note that Nrow x Ncol is the dimension of the input image

% INPUT
% img_feature_array: The Nrow x Ncol x D matrix, each layer d = 1 to D
% represent one feature type. So, this is like stacking feature images
% together. 
% data: NrowxNcol by D matrix obtained from rearranging img_feature_array
% C: the desired number of class labels
% max_iteration: the maximum number of iteration for EM algorithm
% Rep: the number of repetitions for EM to run


% OUTPUT
% I_segm: Nrow by Ncol matrix each element is the MAP class label
% I_posterior: Nrow by Ncol by C cube matrix represent the posterior for each class for each label
% I_max_posterior: Nrow by Ncol matrix each element is the maximum posterior value corresponding to I_segm
% ll: the log-likelihood of the results


[Nrow, Ncol, D] = size(img_feature_array);
data = reshape(img_feature_array(:), [Nrow*Ncol, D]);

tic;
options = statset('Display','final','MaxIter',max_iteration);
gmm_obj = gmdistribution.fit(data,C,'Regularize',1e-4,'Replicates',Rep,'Options',options);
disp(['GMM spend ',num2str(toc),' sec']);
% ------------------------

%  ------ classification using MAP ---------------------------------------
[gmm_posterior, neg_ll] = posterior(gmm_obj,data);
[max_postr, class_result] = max(gmm_posterior,[],2);
ll = -neg_ll;
% --------------------------------------------------------------------

% ------ re-organize the segmentation image --------
I_segm = reshape(class_result(:), [Nrow, Ncol]);
I_max_posterior = reshape(max_postr(:), [Nrow, Ncol]);
I_posterior = reshape(gmm_posterior(:), [Nrow Ncol C]);
end