# yaml2mindmap
Converts a yaml file (to json) to a mind map (in processing) 

This is a processing.org + python app that reads a yaml file, converts it to json format, and generate
a mind map image.

parsey.py is the utility that parses yaml and outputs a json string, readable in processing.
The yaml files should be saved in the data/ folder. The yaml file is intermediately converted to json
for easy loading in processing.

$> python parsey.py ./data/civpro.yaml

yaml2mindmap.pde is the processing app that generates the image.
Edit the project variable to select the yaml source, omitting 'data' folder and the '.yaml' extension.

Press 'i' to save the image, '-' and '+' to zoom in or out.

The python script is automatically called by the processing app.

Some rudiment styling is supported.
