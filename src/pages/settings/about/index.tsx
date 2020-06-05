import React from 'react'
import Logo from '../assets/logo@2x.png'
import './about.scss'
export const AboutPage = () => {
  return (
    <div className='partial-page about-page'>
      <div className='about-logo'>
        <img src={Logo}/>
        <div className='title'>
          Agora Meeting 兼容手机端<br/>版本 V4.0.0.3
        </div>
        {/* <a className='download-link'>下载体验</a> */}
      </div>
      
    </div>
  )
}