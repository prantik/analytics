HIVE_USER := hadoop
HIVE_MASTER := 23.23.92.49
PRIVATE_KEY := ~/.ssh/analytics.pem


upload: upload-s3 upload-hive

upload-hive:
	scp -i $(PRIVATE_KEY) hive/* $(HIVE_USER)@$(HIVE_MASTER):~/

upload-s3:
	python deploy.py -v

hadoop-ui:
	ssh -f -i $(PRIVATE_KEY) -l $(HIVE_USER) -N -L2001:localhost:9100 \
		$(HIVE_MASTER)
	@echo "Now hit localhost:2001 in your browser to see progress of Hadoop jobs."
