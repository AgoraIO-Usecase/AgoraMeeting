import React, { Fragment, useCallback } from 'react'

import {AboutPage} from './about/index'
import {VideoTestPage} from './video/index'
import {AudioTestPage} from './audio/index'
import {ProfilePage} from './profile/index'
import {FeedBackPage} from './feedback/index'

import { Route, useHistory, useLocation, Link } from 'react-router-dom';
import './index.scss'

export const SettingPages = () => {

  const location = useLocation()
  const history = useHistory()

  const Navbar = useCallback(() => {
    if (!location.pathname.match(/setting/)) return null
    return (
      <div className='nav-list'>
        <Link to='/setting' className={location.pathname === '/setting' ? 'active' : ''}>
          <div className='video'>
            视频
          </div>
        </Link>
        <Link to='/setting/audio' className={location.pathname === '/setting/audio' ? 'active' : ''}>
          <div className='audio'>
            音频
          </div>
        </Link>
        <Link to='/setting/profile'  className={location.pathname === '/setting/profile' ? 'active' : ''}>
          <div className='profile'>
            个人
          </div>
        </Link>
        <Link to='/setting/feedback' className={location.pathname === '/setting/feedback' ? 'active' : ''}>
          <div className='feedback'>
            上传日志
          </div>
        </Link>
        <Link to='/setting/about' className={location.pathname === '/setting/about' ? 'active' : ''}>
          <div className='about'>
            关于
          </div>
        </Link>
      </div>
    )
  }, [location.pathname]);

  const handleClose = () => {
    history.push('/')
  }

  return (
  <div className='meeting-facade'>
    <div className='setting-page'>
      <div className='setting-header'>
        <div className='setting-title'>设置</div>
        <div className='close' onClick={handleClose}></div>
      </div>
      <div className='setting-body'>
        <div className='navbar'>
          <Navbar></Navbar>
        </div>
        <div className='content'>
          <Fragment>
            <Route exact path='/setting'>
              <VideoTestPage />
            </Route>
            <Route exact path='/setting/audio'>
              <AudioTestPage />
            </Route>
            <Route exact path='/setting/profile'>
              <ProfilePage />
            </Route>
            <Route exact path='/setting/feedback'>
              <FeedBackPage />
            </Route>
            <Route exact path='/setting/about'>
              <AboutPage />
            </Route>
          </Fragment>
        </div>
      </div>
    </div>
  </div>
  )
}

export default () => (<SettingPages />)