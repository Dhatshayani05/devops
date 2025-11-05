module "dpg_novmeber_elb" {
  source                   = "./modules/elastic_load_balancer"
  security_group_id        = data.aws_security_group.sg.id
  subnet_id                = data.aws_subnet.sn.id
  UNIQUE_ANIMAL_IDENTIFIER = var.UNIQUE_ANIMAL_IDENTIFIER
}

module "dpg_november_asg" {
  source                   = "./modules/autoscaling_group"
  security_group_id        = data.aws_security_group.sg.id
  subnet_id                = data.aws_subnet.sn.id
  elb_id                   = module.dpg_novmeber_elb.elb_id
  UNIQUE_ANIMAL_IDENTIFIER = var.UNIQUE_ANIMAL_IDENTIFIER
  ARTIFACT                 = var.ARTIFACT
}
data "aws_security_group" "sg" {
  tags = {
    "Purpose" = "Playground"
  }
}
data "aws_subnet" "sn"{
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Purpose = "Playground"
    count = 0
  }
}
data "aws_vpc" "vpc"{
  tags = {
    Purpose = "Playground"
  }
}