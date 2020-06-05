import React, { Suspense } from 'react';
import { HashRouter as Router, Switch } from 'react-router-dom';
import { Loading } from '@/components/loading';

function CustomBrowserRouter ({children}: any) {
  return (
    <Router>
      <Suspense fallback={<Loading />}>
        <Switch>
          {children}
        </Switch>
      </Suspense>
    </Router>
  )
}

// const Loading = () => {
//   return (
//     <div>
//       Loading...
//     </div>
//   )
// }

export default CustomBrowserRouter;