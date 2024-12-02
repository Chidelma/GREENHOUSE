.PHONY: clean create destroy

-include .makevars.mk

# Set INITIALS to 'null' as a default placeholder
INITIALS ?= null

# Validate INITIALS is not null
ifeq ($(INITIALS),null)
    $(error "INITIALS variable not set and could not be derived. Please set before running")
endif

init:
	terraform init -backend-config="key=aws-practical/terraform/$(INITIALS)"

create: init clean
	terraform apply -var identifier=$(INITIALS)

plan: init
	terraform plan -var identifier=$(INITIALS)

destroy: init
	terraform destroy -var identifier=$(INITIALS)

clean:
	@find . -name '*~' -exec rm {} \;

apply:
	terraform apply -var identifier=$(INITIALS)

prepare:
	gh repo create grnhse/aws-practical-$(INITIALS) --description="AWS Practical Interview Repository for $(INITIALS)" --template="grnhse/aws-practical" --internal
