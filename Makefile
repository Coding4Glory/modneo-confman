PLENARY_INIT = tests/init.lua
TESTS_DIR = tests
ENABLED_DIR = enabled

.PHONY: test clean


MOCKS := ${TESTS_DIR}/fixture/cat_one/mod_one.lua ${TESTS_DIR}/fixture/cat_one/mod_two.lua ${TESTS_DIR}/fixture/cat_two/mod_three.lua ${TESTS_DIR}/fixture/cat_two/mod_four.lua

RW_MOCKS := $(subst fixture,fixture_rw,${MOCKS})

$(MOCKS) $(RW_MOCKS):
	@mkdir -p $(@D)
	@echo -e "vim.g.confman_test_$(notdir $(@:%.lua=%)) = 1\n" > $@

WRITE_DIRS := ${TESTS_DIR}/fixture/enabled ${TESTS_DIR}/fixture_rw/enabled

$(WRITE_DIR):
	@mkdir -p $@

test: $(MOCKS) ${RW_MOCKS} $(WRITE_DIRS)
	@nvim \
		--headless \
		--noplugin \
		-u ${PLENARY_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${PLENARY_INIT}' }"

clean:
	@rm -rf /tmp/plenary.nvim
	@rm -rf ${TESTS_DIR}/fixture
	@rm -rf ${WRITE_DIRS}
