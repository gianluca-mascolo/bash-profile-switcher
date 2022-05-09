BASHRC_PATH := $(HOME)/.bashrc
BASHRC_CHECK_INSTALL := $(shell grep -q .bash_profile_switcher $(BASHRC_PATH) 2> /dev/null)
BASHRC_INSTALL_STATUS := $(.SHELLSTATUS)
BASHRC_INSTALL_LINE := source ~/.bash_profile_switcher
EMPTY_LINE := $()

test:
	./tests/automated_tests.exp
clean:
	docker-compose down
install:
	install -m 0644 -C bash_profile_switcher.sh $(HOME)/.bash_profile_switcher
ifneq ("$(BASHRC_INSTALL_STATUS)","0")
	$(file >> $(BASHRC_PATH),$(EMPTY_LINE))
	$(file >> $(BASHRC_PATH),$(BASHRC_INSTALL_LINE))
endif
