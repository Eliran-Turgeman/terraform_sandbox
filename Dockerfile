FROM amazonlinux:2
WORKDIR /opt/cloudmapper
ENV secret = AKIAIOSFODNN7EXAMAAA
# Braintree Access Token
Braintree_Access_Token = "access_token$production$x0lb8affpzmmnufd$3ea7cb281754b7da7eca131ef9642324"
# AWS MWS Auth Token
AWS_MWS_Auth_Token = "amzn.mws.f90f3ce6-9b5a-26a7-9a87-4ff8052be2ec"
# Paypal Token Id
Paypal_Token_Id = "Juq9JAE-NyaGNQ3AIUWcNlE5Z8k_VfdynYd7H7o96FOwsnOFVL41OcpAtpyoW8xgBIYMBwOpzFLEOfTy"
# Paypal Token Key
paypal_token_key = "AKzRybPsQhernBYK0wK8NQyzr4Pd2z31OYn8EFRnL9E4qP5xizJdPZzBi1aN82cpNEad1-JOKcyMW8w3"
# Braintree Payments Id
braintree_payments_id = "braintree03213079d57e13b40802a9805f58d691"
# Braintree Payments Key
braintree_payments_key = "braintreetxti3hwdp3fld1lu"
#readme 
readme = "rdme_xn8s9h0def16cebfb007195c89e1b4fa03db15085ef66f644af258d0a56b9e663c7084"
RUN yum update -y && yum install -y dracut-fips openssl
RUN yum install -y python3 python3-pip
RUN yum install -y bash musl-dev gcc build-essential autoconf libtool python3-tk jq awscli git
RUN yum install -y automake python3-devel python3-tkinter
