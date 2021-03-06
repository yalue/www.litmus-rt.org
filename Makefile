MARKDOWN ?= multimarkdown
PUBLIC_WEB_DIR ?= /www/sws-websites/www.litmus-rt.org

.PHONY: all publish autoupdate clean

MD := $(shell find . -name '*.md')
HTML_TO_GENERATE := $(subst md,html,${MD})

%.html: %.md inc/*.markdown
	@echo '[MD]' $< '->' $@
	@${MARKDOWN} --process-html --full -t html -o $@ $<

all: ${HTML_TO_GENERATE}

clean:
	rm -f ${HTML_TO_GENERATE}

publish: all
	@echo '[UP] copying to' ${PUBLIC_WEB_DIR}
	@rsync -a --delete \
		--exclude Makefile \
		--exclude '*.md' \
		--exclude '*.markdown' \
		--exclude '.git*' \
		--exclude '*.log' \
		--exclude '*.qcow.gz' \
		--exclude '*.qcow.tar.gz' \
		--exclude '*.qcow.tgz' \
		. ${PUBLIC_WEB_DIR}

autoupdate:
	@if ! git pull | grep -q 'Already up-to-date.'; \
	then \
		echo "[UP] pulled an update on" `date`; \
		make publish; \
	fi

public:
	git push && git checkout public && git merge master && git push && git checkout master
