
WORKING_DIR=$(PWD)

OPENSSL=openssl
SSL_GENRSA_FLAGS=-aes256 2048
SSL_CA_FLAGS=-notext -create_serial


ROOT_CN=RootCA
ROOT_CA_DIR=$(WORKING_DIR)/RootCA
ROOT_CA_DATA_DIR=$(ROOT_CA_DIR)/data
ROOT_PRIVATE_FILE=$(ROOT_CA_DIR)/RootCA.key
ROOT_PUBLIC_FILE=$(ROOT_CA_DIR)/RootCA.crt

INTERMEDIATE_CN=IntermediateCA
INTERMEDIATE_CA_DIR=$(WORKING_DIR)/IntermediateCA
INTERMEDIATE_CA_DATA_DIR=$(INTERMEDIATE_CA_DIR)/data
INTERMEDIATE_PRIVATE_FILE=$(INTERMEDIATE_CA_DIR)/IntermediateCA.key
INTERMEDIATE_REQUEST_FILE=$(INTERMEDIATE_CA_DIR)/IntermediateCA.csr
INTERMEDIATE_PUBLIC_FILE=$(INTERMEDIATE_CA_DIR)/IntermediateCA.crt

SERVER_CN=Server
SERVER_DIR=$(WORKING_DIR)/Server
SERVER_DATA_DIR=$(SERVER_DIR)/data
SERVER_PRIVATE_FILE=$(SERVER_DIR)/Server.key
SERVER_REQUEST_FILE=$(SERVER_DIR)/Server.csr
SERVER_PUBLIC_FILE=$(SERVER_DIR)/Server.crt
SERVER_PKCS_FILE=$(SERVER_DIR)/Server.pfx

CLIENT_CN=Client
CLIENT_DIR=$(WORKING_DIR)/Client
CLIENT_DATA_DIR=$(CLIENT_DIR)/data
CLIENT_PRIVATE_FILE=$(CLIENT_DIR)/Client.key
CLIENT_REQUEST_FILE=$(CLIENT_DIR)/Client.csr
CLIENT_PUBLIC_FILE=$(CLIENT_DIR)/Client.crt
CLIENT_PKCS_FILE=$(CLIENT_DIR)/Client.pfx

certs: root_certs intermediate_certs server_certs client_certs

root_certs: root_dir $(ROOT_PRIVATE_FILE) $(ROOT_PUBLIC_FILE)

intermediate_certs: intermediate_dir $(INTERMEDIATE_PRIVATE_FILE) $(INTERMEDIATE_PUBLIC_FILE)

server_certs: server_dir $(SERVER_PRIVATE_FILE) $(SERVER_PUBLIC_FILE) $(SERVER_PKCS_FILE)

client_certs: client_dir $(CLIENT_PRIVATE_FILE) $(CLIENT_PUBLIC_FILE) $(CLIENT_PKCS_FILE)

root_dir: $(ROOT_CA_DIR) $(ROOT_CA_DATA_DIR) $(ROOT_CA_DATA_DIR)/certs $(ROOT_CA_DATA_DIR)/index.txt

intermediate_dir: $(INTERMEDIATE_CA_DIR) $(INTERMEDIATE_CA_DATA_DIR) $(INTERMEDIATE_CA_DATA_DIR)/certs $(INTERMEDIATE_CA_DATA_DIR)/index.txt

server_dir: $(SERVER_DIR)

client_dir: $(CLIENT_DIR)

$(ROOT_CA_DIR):
	mkdir $@

$(ROOT_CA_DATA_DIR):
	mkdir $@

$(ROOT_CA_DATA_DIR)/certs:
	mkdir $@

$(ROOT_CA_DATA_DIR)/index.txt:
	touch $@

$(INTERMEDIATE_CA_DIR):
	mkdir $@

$(INTERMEDIATE_CA_DATA_DIR):
	mkdir $@

$(INTERMEDIATE_CA_DATA_DIR)/certs:
	mkdir $@

$(INTERMEDIATE_CA_DATA_DIR)/index.txt:
	touch $@

$(SERVER_DIR):
	mkdir $@

$(CLIENT_DIR):
	mkdir $@

$(ROOT_PRIVATE_FILE):
	$(OPENSSL) genrsa -out $@ $(SSL_GENRSA_FLAGS)

$(ROOT_PUBLIC_FILE): $(ROOT_PRIVATE_FILE)
	$(OPENSSL) req -x509 -new -key $< -days 365 -out $@ -subj /CN=$(ROOT_CN)

$(INTERMEDIATE_PRIVATE_FILE):
	$(OPENSSL) genrsa -out $@ $(SSL_GENRSA_FLAGS)

$(INTERMEDIATE_REQUEST_FILE): $(INTERMEDIATE_PRIVATE_FILE)
	$(OPENSSL) req -new -key $< -out $@ -subj /CN=$(INTERMEDIATE_CN)

$(INTERMEDIATE_PUBLIC_FILE): $(INTERMEDIATE_REQUEST_FILE)
	$(OPENSSL) ca -config NewIntermediate.cnf -in $< -out $@ $(SSL_CA_FLAGS)

$(SERVER_PRIVATE_FILE):
	$(OPENSSL) genrsa -out $@ $(SSL_GENRSA_FLAGS)

$(SERVER_REQUEST_FILE): $(SERVER_PRIVATE_FILE)
	$(OPENSSL) req -new -key $< -out $@ -subj /CN=$(SERVER_CN)

$(SERVER_PUBLIC_FILE): $(SERVER_REQUEST_FILE)
	$(OPENSSL) ca -config NewServer.cnf -in $< -out $@ $(SSL_CA_FLAGS)

$(SERVER_PKCS_FILE): $(SERVER_PRIVATE_FILE) $(SERVER_PUBLIC_FILE)
	$(OPENSSL) pkcs12 -export -inkey $< -in $(SERVER_PUBLIC_FILE) -out $@

$(CLIENT_PRIVATE_FILE):
	$(OPENSSL) genrsa -out $@ $(SSL_GENRSA_FLAGS)

$(CLIENT_REQUEST_FILE): $(CLIENT_PRIVATE_FILE)
	$(OPENSSL) req -new -key $< -out $@ -subj /CN=$(CLIENT_CN)

$(CLIENT_PUBLIC_FILE): $(CLIENT_REQUEST_FILE)
	$(OPENSSL) ca -config NewClient.cnf -in $< -out $@ $(SSL_CA_FLAGS)

$(CLIENT_PKCS_FILE): $(CLIENT_PRIVATE_FILE) $(CLIENT_PUBLIC_FILE)
	$(OPENSSL) pkcs12 -export -inkey $< -in $(CLIENT_PUBLIC_FILE) -out $@