.PHONY: all question1 question2 report test clean

all: question1 question2

question1:
	Rscript question1.R

question2:
	Rscript question2.R

report:
	Rscript -e "rmarkdown::render('report.Rmd', output_format='html_document')"

test:
	Rscript -e "library(cluster); library(ggplot2); library(plotly); library(rmarkdown)"

clean:
	rm -f *.png *.csv *.html