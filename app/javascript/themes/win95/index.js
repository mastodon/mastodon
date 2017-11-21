//  These lines are the same as in glitch:
import 'font-awesome/css/font-awesome.css';
require.context('../../images/', true);

//  …But we want to use our own styles instead.
import 'styles/win95.scss';

//  Be sure to make this style file import from
//  `themes/glitch/styles/index.scss` (the glitch styling), and not
//  `application.scss` (which are the vanilla styles).
