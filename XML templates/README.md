# Contents

## ePI FHIR message template 

The objective of the ePI (FHIR) [template](https://github.com/EuropeanMedicinesAgency/ePI-consultation/blob/master/XML%20templates/ePI_template.xml) is to be used by template engines to transform PI information, in structured or semi-structured format (e.g. JSON, CSV, ...), to an ePI FHIR message.
Items in the template, marked with "${}" will be replaced by Product Information (PI) data entities. 

The resulting ePI XML [message](https://github.com/EuropeanMedicinesAgency/ePI-consultation/blob/master/XML%20templates/ePI_template_instance.xml) contains a FHIR resource, a Bundle of Bundles, each of which is a document having a Composition, and supporting resources.

Please refer to the [ePI API specification](https://github.com/EuropeanMedicinesAgency/ePI-consultation/blob/master/API%20specification/Draft-ePI-API-Specification-v1.pdf) for more information on the structure for the ePI FHIR message.

<p align="center">
<img src="./ePI template.png" alt="Getting started" />
<figcaption>Figure 1.</figcaption>
</p>

For demo purposes, please find [here](https://github.com/EuropeanMedicinesAgency/ePI-consultation/blob/master/XML%20templates/QRDbundleToHtml.xsl) an XSL stylesheet, converting ePI messages to HTML. 

An example of an XSL tranformation engine can be found [here](https://www.saxonica.com/html/documentation10/using-xsl/).