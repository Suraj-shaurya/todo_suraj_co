module "resource_group_name" {
  source                  = "../MODULES/azurerm_resource_group"
  resource_group_name     = "todoapp_suraj"
  resource_group_location = "centralindia"
}

module "resource_group_name" {
  source                  = "../MODULES/azurerm_resource_group"
  resource_group_name     = "todoapp_suraj_1"
  resource_group_location = "centralindia"
}


module "virtual_network" {
  source                   = "../MODULES/azurerm_vitual_network"
  virtual_network_name     = "vnet_todo_suraj"
  virtual_network_location = "centralindia"
  resource_group_name      = "todoapp_suraj"
  address_space            = ["10.0.0.0/16"]
  depends_on               = [module.resource_group_name]

}
#dard 1- do baar subnet ka code repeat

module "frontend_subnet" {
  source               = "../MODULES/azurerm_subnet"
  depends_on           = [module.virtual_network]
  subnet_name          = "frontened-subnet_suraj"
  resource_group_name  = "todoapp_suraj"
  virtual_network_name = "vnet_todo_suraj"
  address_prefixes     = [ "10.0.1.0/24"]
}

module "backend_subnet" {
  source               = "../MODULES/azurerm_subnet"
  depends_on           = [module.virtual_network]
  subnet_name          = "backened-subnet_suraj"
  virtual_network_name = "vnet_todo_suraj"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = "todoapp_suraj"
}

module "public_ip_frontened" {
  source              = "../MODULES/azurerm_public_ip"
  resource_group_name = "todoapp_suraj"
  location            = "centralindia"
  allocation_method   = "Static"
  public_ip_name      = "pip-todoapp-frontend_suraj"

}

  


# Dard 2 - Do baar module bulana pad raha hai..  do vm ke lie...

module "frontened_vm" {
  source               = "../MODULES/azurerm_vitual_machine"
  depends_on           = [module.frontend_subnet]
  resource_group_name  = "todoapp_suraj"
  location             = "centralindia"
  vm_name              = "vm-frontend_suraj"
  vm_size              = "Standard_B1s"
  admin_username       = "front_vm_suraj"
  admin_password       = "Suraj@123456"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "nic-vm-frontend"
  pip_name             = "pip-todoapp-frontend_suraj"
  virtual_network_name = "vnet_todo_suraj"
  subnet_name          = "frontened-subnet_suraj"

}


module "public_ip_backened" {
  source              = "../MODULES/azurerm_public_ip"
  resource_group_name = "todoapp_suraj"
  location            = "centralindia"
  allocation_method   = "Static"
  public_ip_name      = "pip-todoapp-backened_suraj"

}
module "backened_vm" {
  depends_on           = [module.backend_subnet]
  source               = "../MODULES/azurerm_vitual_machine"
  resource_group_name  = "todoapp_suraj"
  location             = "centralindia"
  vm_name              = "vm-backened_suraj"
  vm_size              = "Standard_B1s"
  admin_username       = "backened_vm_suraj"
  admin_password       =  "Suraj@123456"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "nic-vm-backened"
  pip_name             = "pip-todoapp-backened_suraj"
  virtual_network_name = "vnet_todo_suraj"
  subnet_name          = "backened-subnet_suraj"

}

module "sql_server" {
  source              = "../modules/azurerm_sql_server"
  sql_server_name     = "todosqlserver008"
  resource_group_name = "todoapp_suraj"
  location            = "centralindia"
  # secret ko rakhne ka sudhar - Azure Key Vault
  administrator_login          = "sqladmin"
  administrator_login_password = "Suraj@123456"

}
module "sql_database" {
  depends_on = [module.sql_server]
  source     = "../modules/azurerm_sql_database"
sql_database_name = "sqldata_suraj"

}

module "key_vault" {
  source              = "../MODULES/azurerm_keyvault"
  key_vault_name      = "sonamkitijori"
  location            = "centralindia"
  resource_group_name = "todoapp_suraj"
}

module "vm_password" {
  source              = "../MODULES/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "sonamkitijori"
  resource_group_name = "todoapp_suraj"
  secret_name         = "vm-password"
  secret_value        = "P@ssw01rd@123"
}

module "vm_username" {
  source              = "../MODULES/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "sonamkitijori"
  resource_group_name = "todoapp_suraj"
  secret_name         = "vm-username"
  secret_value        = "devopsadmin"
}

