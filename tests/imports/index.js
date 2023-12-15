import TestComponentA from "../components/A";
import TestComponentB from "../components/B";
import TestComponentC from "../components/C";
import TestComponentD from "../components/D";
import TestComponentE from "../components/E";
import TestComponentF from "../components/F";
import TestComponentG from "../components/G";
import TestComponentH from "../components/H";
import TestComponentI from "../components/I";
import TestComponentJ2 from "../components/J";
import TestComponentK from "../components/K";
import TestComponentL from "../components/L";
import TestComponentM from "../components/M";

const routes = [
    { 
        path: '/path/to/component', 
        exact: true, 
        component: lazy(() => import('../components/N')) 
    },
]