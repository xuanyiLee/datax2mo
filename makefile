all: build grant_priv

build:
	cd ./cmd/check && go build && mv check ../../
	cd ./cmd/create_table && go build && mv create_table ../../
	cd ./cmd/transfer && go build && mv transfer ../../
	cd ./cmd/gen_data && go build && mv gen_data ../../
	cd ./cmd/load_data && go build && mv load_data ../../

grant_priv:
	chmod -R 0755 ./ssb/bin && chmod -R 0755 ./tpch/bin && chmod -R 0755 ./tpcc/bin && chmod -R 0755 ./tpcds/bin