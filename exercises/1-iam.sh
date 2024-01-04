aws iam create-user --user-name piet
aws iam create-group --group-name devops
aws iam add-user-to-group --group-name devops --user-name piet
