import qui.qui;
import qui.widgets;
import radarwidget;

import utils.misc;

void main(){
	QTerminal term = new QTerminal();
	RadarWidget radar = new RadarWidget();
	term.addWidget(radar);
	term.run();
	.destroy(radar);
	.destroy(term);
}
