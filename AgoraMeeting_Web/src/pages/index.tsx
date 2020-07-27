import React, { lazy } from 'react';
import { Route } from 'react-router-dom';
import CustomBrowserRouter from '@/containers/custom-browser-router';
import ThemeContainer from '@/containers/theme-container';
import Loading from '@/components/loading';
import Toast from '@/components/toast';
import '../icons.scss';
import { RootProvider } from '@/containers/root-container';
import RoomDialog from '@/components/dialog';
import { HomePage as Home } from '@/pages/home/index'
import { SettingPages as Setting } from '@/pages/settings/index'
import { MeetingPages as Meeting } from '@/pages/meeting/index'

export default function () {
  return (
    <ThemeContainer>
      <CustomBrowserRouter>
        <RootProvider>
          <Loading />
          <Toast />
          <RoomDialog />
          <Route exact path='/meeting' component={Meeting} />
          <Route path='/setting' component={Setting} />
          <Route exact path='/' component={Home} />
        </RootProvider>
      </CustomBrowserRouter>
    </ThemeContainer>
  )
}