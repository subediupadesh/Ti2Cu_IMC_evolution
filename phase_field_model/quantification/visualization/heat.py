import streamlit as st
import numpy as np
import plotly.graph_objects as go

def gaussian_3d(A, C, x, y, power, absorptance, beam_radius):

    r = (x**2 + y**2)**0.5
    F = np.where(beam_radius - r < 0, 0, 1)

    # return power * absorptance * np.exp(-(x**2 + y**2) / (2 * beam_radius**2))
    return F*((A*power*absorptance)/(np.pi*beam_radius**2))*np.exp(-C*(x**2 + y**2)/beam_radius**2)

def plot_gaussian_heat_distribution(A, C, power, absorptance, beam_radius, i):
    # Generate data
    x = np.linspace(-400e-6, 400e-6, 100)
    y = np.linspace(-400e-6, 400e-6, 100)
    x, y = np.meshgrid(x, y)
    z = gaussian_3d(A, C, x, y, power, absorptance, beam_radius)
    
    cmaps = ['balance', 'bluered', 'hsv', 'jet', 'picnic', 'portland', 'rainbow', 'rdylbu_r', 'spectral_r', 'turbo']
    # i=6
    st.write(cmaps[i])
    fig = go.Figure(data=[go.Surface(z=z, x=x, y=y, colorscale=cmaps[i])])

    fig.update_layout(scene=dict(xaxis_title='X-axis', yaxis_title='Y-axis', zaxis_title='Intensity'),
                      title='3D Gaussian Heat Distribution',
                      width=2500,  # Set width to 800 pixels
                      height=1000)  # Set height to 600 pixels

    return fig

st.title('Gaussian and Flat-top Heat Source')

st.sidebar.header('Parameters')
power = st.sidebar.slider('Power', min_value=1, max_value=5000, value=1000, step=1)
absorptance = st.sidebar.slider('Absorptance', min_value=1.0e7, max_value=1.0e9, value=8.5e7, step=1.0e7)
beam_radius = st.sidebar.slider('Beam Radius', min_value=100.0e-6, max_value=500.0e-6, value=222.5e-6, step=0.000001)

A = st.sidebar.slider('A', min_value=0.00001, max_value=5.0, value=2.0, step=0.0001)
C = st.sidebar.slider('C', min_value=0.0000001, max_value=1.0, value=0.5, step=0.0001)
i = st.sidebar.slider('colormap', min_value=0, max_value=9, value=6, step=1)

fig = plot_gaussian_heat_distribution(A, C, power, absorptance, beam_radius, i)

# Show the plot
st.plotly_chart(fig, use_container_width=True)



# (2**(1/k)*P)/(np.pi*rs**2*G*(1/k))*np.exp(-2*((x**2+y**2)/rs**2)**k)