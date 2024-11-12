data "aws_caller_identity" "current" {}

data "archive_file" "get_denuncia_code" {
    type = "zip"
    source_file = "lamda_functions/getDenuncia.py"
    output_path = "output_lambda_functions/lambda_getDenuncia_src.zip"
}

data "archive_file" "post_denuncia_code" {
    type = "zip"
    source_file = "lamda_functions/postDenuncia.py"
    output_path = "output_lambda_functions/lambda_postDenuncia_src.zip"
}

data "archive_file" "redirect_code" {
    type = "zip"
    source_file = "lamda_functions/redirect.py"
    output_path = "output_lambda_functions/lambda_redirect_src.zip"
}

data "archive_file" "quejasSNS_code" {
    type = "zip"
    source_file = "lamda_functions/quejasSNS.py"
    output_path = "output_lambda_functions/quejasSNS_src.zip"
}

data "archive_file" "reservasSNS_code" {
    type = "zip"
    source_file = "lamda_functions/reservasSNS.py"
    output_path = "output_lambda_functions/reservasSNS_src.zip"
}

data "archive_file" "addReserva_code" {
    type = "zip"
    source_file = "lamda_functions/addReserva.py"
    output_path = "output_lambda_functions/lambda_addReserva_src.zip"
}

data "archive_file" "getReserva_code" {
    type = "zip"
    source_file = "lamda_functions/getReserva.py"
    output_path = "output_lambda_functions/lambda_getReserva_src.zip"
}

data "archive_file" "presignedUrl_code" {
    type = "zip"
    source_file = "lamda_functions/presignedUrl.py"
    output_path = "output_lambda_functions/lambda_presignedUrl_src.zip"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "archive_file" "subscribeSNS_code" {
    type = "zip"
    source_file = "lamda_functions/subscribeSNS.py"
    output_path = "output_lambda_functions/lambda_subscribeSNS_src.zip"
}
