INSTALL_PATH := $(HOME)
BASHRC_PATH := $(HOME)/.bashrc
BASHRC_INSTALL_LINE := source $(INSTALL_PATH)/.bash_profile_switcher
BASHRC_CHECK_INSTALL := $(findstring $(BASHRC_INSTALL_LINE),$(file < $(BASHRC_PATH)))
ifeq  ("$(BASHRC_CHECK_INSTALL)","$(BASHRC_INSTALL_LINE)")
	BASHRC_INSTALL_STATUS := 0
else
	BASHRC_INSTALL_STATUS := 1
endif

test:
	echo "Checking shell format..."
	docker run --rm -v "$(PWD)/bash_profile_switcher.sh:/tmp/bash_profile_switcher.sh:ro" mvdan/shfmt:v3 -d -i 4 /tmp/bash_profile_switcher.sh
	echo "Analyze with shellcheck..."
	shellcheck bash_profile_switcher.sh
	docker pull bash:5
	./tests/automated_tests.exp
clean:
	docker-compose down
install:
	install -m 0644 -C bash_profile_switcher.sh $(INSTALL_PATH)/.bash_profile_switcher
ifneq ("$(BASHRC_INSTALL_STATUS)","0")
	$(file >> $(BASHRC_PATH),$())
	$(file >> $(BASHRC_PATH),$(BASHRC_INSTALL_LINE))
endif
