#!/usr/bin/env python3
"""
Recreation of climate data plots from the Excel workbook
Creates plots with dark background and pleasing color scheme
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from pathlib import Path

# Set up the plotting style - dark background with pleasing colors
plt.style.use('dark_background')
sns.set_palette("husl")

# Custom color palette for better aesthetics
colors = {
    'winter': '#64B5F6',      # Light blue
    'spring': '#81C784',      # Light green  
    'annual': '#FFB74D',      # Light orange
    'highlight': '#F06292',   # Pink for 2007 line
}

def load_data():
    """Load data from the Excel file"""
    data_path = Path("Misc./climate-data.xlsx")
    
    # Load the data sheet
    df_data = pd.read_excel(data_path, sheet_name='data', header=1)
    
    # Load the monthly sheet
    df_monthly = pd.read_excel(data_path, sheet_name='Monthly')
    
    return df_data, df_monthly

def create_yearly_temperature_plot(df_data):
    """Create the main yearly temperature plot from the data sheet"""
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Plot the temperature trends
    ax.plot(df_data['Year'], df_data['Winter (Jan - Mar)'], 
           marker='o', linewidth=2.5, markersize=6, 
           color=colors['winter'], label='Winter (Jan-Mar)', alpha=0.8)
    
    ax.plot(df_data['Year'], df_data['Spring (Apr - Jun)'], 
           marker='s', linewidth=2.5, markersize=6, 
           color=colors['spring'], label='Spring (Apr-Jun)', alpha=0.8)
    
    ax.plot(df_data['Year'], df_data['Annual (Jan - Dec)'], 
           marker='^', linewidth=2.5, markersize=6, 
           color=colors['annual'], label='Annual (Jan-Dec)', alpha=0.8)
    
    # Add vertical line at 2007
    ax.axvline(x=2007, color=colors['highlight'], linestyle='--', 
              linewidth=2, alpha=0.8, label='2007 Reference')
    
    # Add connecting lines from 2007 to 2020 for each series
    year_2007_idx = df_data[df_data['Year'] == 2007].index[0]
    year_2020_idx = df_data[df_data['Year'] == 2020].index[0]
    
    # Winter connecting line
    ax.plot([2007, 2020], 
           [df_data.loc[year_2007_idx, 'Winter (Jan - Mar)'], 
            df_data.loc[year_2020_idx, 'Winter (Jan - Mar)']], 
           color=colors['winter'], linestyle=':', linewidth=3, alpha=0.7)
    
    # Spring connecting line  
    ax.plot([2007, 2020], 
           [df_data.loc[year_2007_idx, 'Spring (Apr - Jun)'], 
            df_data.loc[year_2020_idx, 'Spring (Apr - Jun)']], 
           color=colors['spring'], linestyle=':', linewidth=3, alpha=0.7)
    
    # Annual connecting line
    ax.plot([2007, 2020], 
           [df_data.loc[year_2007_idx, 'Annual (Jan - Dec)'], 
            df_data.loc[year_2020_idx, 'Annual (Jan - Dec)']], 
           color=colors['annual'], linestyle=':', linewidth=3, alpha=0.7,
           label='2007-2020 Trend')
    
    # Customize the plot
    ax.set_xlabel('Year', fontsize=14, fontweight='bold')
    ax.set_ylabel('Average Temperature (°C)', fontsize=14, fontweight='bold')
    ax.set_title('Climate Temperature Trends (2000-2020)\nMendocino County', 
                fontsize=16, fontweight='bold', pad=20)
    
    # Improve grid and aesthetics
    ax.grid(True, alpha=0.3, linestyle='-', linewidth=0.5)
    ax.set_facecolor('#1a1a1a')
    
    # Set axis limits
    ax.set_xlim(2000, 2020)
    y_min = df_data[['Winter (Jan - Mar)', 'Spring (Apr - Jun)', 'Annual (Jan - Dec)']].min().min()
    y_max = df_data[['Winter (Jan - Mar)', 'Spring (Apr - Jun)', 'Annual (Jan - Dec)']].max().max()
    ax.set_ylim(y_min - 0.5, y_max + 0.5)
    
    # Set x-axis ticks to show integer years only
    ax.set_xticks(range(2000, 2020, 1))  # Show every year
    ax.tick_params(axis='x', which='major', labelsize=11)
    
    # Customize legend
    legend = ax.legend(loc='upper left', framealpha=0.9, fontsize=11)
    legend.get_frame().set_facecolor('#2a2a2a')
    
    # Add annotations for key years
    ax.annotate('2007', xy=(2007, y_max + 0.2), xytext=(2007, y_max + 0.4),
               ha='center', fontsize=10, color=colors['highlight'],
               arrowprops=dict(arrowstyle='->', color=colors['highlight'], alpha=0.7))
    
    plt.tight_layout()
    return fig

def create_monthly_comparison_plot(df_monthly):
    """Create monthly temperature comparison plot between 2007 and 2020"""
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))
    
    # Filter out the summary rows (Winter and Spring)
    monthly_data = df_monthly[df_monthly['Avg. monthly Temp, Mendocino County(°F)'].str.contains('Winter|Spring') == False].copy()
    monthly_data = monthly_data.reset_index(drop=True)
    
    months = monthly_data['Avg. monthly Temp, Mendocino County(°F)']
    temp_2007 = monthly_data['2007 C']
    temp_2020 = monthly_data['2020 C']
    
    # Top plot: Monthly temperatures comparison
    x_pos = np.arange(len(months))
    width = 0.35
    
    bars1 = ax1.bar(x_pos - width/2, temp_2007, width, 
                   label='2007', color=colors['winter'], alpha=0.8)
    bars2 = ax1.bar(x_pos + width/2, temp_2020, width, 
                   label='2020', color=colors['spring'], alpha=0.8)
    
    ax1.set_xlabel('Month', fontsize=12, fontweight='bold')
    ax1.set_ylabel('Temperature (°C)', fontsize=12, fontweight='bold')
    ax1.set_title('Monthly Temperature Comparison: 2007 vs 2020\nMendocino County', 
                 fontsize=14, fontweight='bold')
    ax1.set_xticks(x_pos)
    ax1.set_xticklabels(months, rotation=45, ha='right')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_facecolor('#1a1a1a')
    
    # Bottom plot: Temperature differences
    temp_diff = monthly_data['diff C']
    colors_diff = [colors['spring'] if x > 0 else colors['winter'] for x in temp_diff]
    
    bars3 = ax2.bar(x_pos, temp_diff, color=colors_diff, alpha=0.8)
    ax2.axhline(y=0, color='white', linestyle='-', linewidth=1, alpha=0.5)
    
    ax2.set_xlabel('Month', fontsize=12, fontweight='bold')
    ax2.set_ylabel('Temperature Difference (°C)', fontsize=12, fontweight='bold')
    ax2.set_title('Temperature Change (2020 - 2007)', fontsize=14, fontweight='bold')
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels(months, rotation=45, ha='right')
    ax2.grid(True, alpha=0.3)
    ax2.set_facecolor('#1a1a1a')
    
    # Add value labels on the difference bars
    for i, (bar, diff) in enumerate(zip(bars3, temp_diff)):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height + (0.1 if height > 0 else -0.2),
                f'{diff:.1f}°C', ha='center', va='bottom' if height > 0 else 'top',
                fontsize=9, fontweight='bold')
    
    plt.tight_layout()
    return fig

def create_summary_statistics_plot(df_data, df_monthly):
    """Create a summary statistics visualization"""
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(16, 12))
    
    # Plot 1: Temperature trend over time with regression lines
    years = df_data['Year']
    
    for col, color, label in [('Winter (Jan - Mar)', colors['winter'], 'Winter'),
                             ('Spring (Apr - Jun)', colors['spring'], 'Spring'),
                             ('Annual (Jan - Dec)', colors['annual'], 'Annual')]:
        temps = df_data[col]
        ax1.scatter(years, temps, color=color, alpha=0.7, s=50, label=label)
        
        # Add trend line
        z = np.polyfit(years, temps, 1)
        p = np.poly1d(z)
        ax1.plot(years, p(years), color=color, linestyle='--', alpha=0.8, linewidth=2)
    
    ax1.axvline(x=2007, color=colors['highlight'], linestyle=':', alpha=0.7)
    ax1.set_xlabel('Year', fontweight='bold')
    ax1.set_ylabel('Temperature (°C)', fontweight='bold')
    ax1.set_title('Temperature Trends with Regression Lines', fontweight='bold')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax1.set_facecolor('#1a1a1a')
    
    # Set x-axis ticks to show integer years only
    ax1.set_xticks(range(2000, 2021, 2))  # Show every 2 years
    ax1.tick_params(axis='x', which='major', labelsize=10)
    
    # Plot 2: Distribution of temperatures by season
    winter_temps = df_data['Winter (Jan - Mar)']
    spring_temps = df_data['Spring (Apr - Jun)']
    annual_temps = df_data['Annual (Jan - Dec)']
    
    ax2.hist(winter_temps, bins=8, alpha=0.7, color=colors['winter'], label='Winter', density=True)
    ax2.hist(spring_temps, bins=8, alpha=0.7, color=colors['spring'], label='Spring', density=True)
    ax2.hist(annual_temps, bins=8, alpha=0.7, color=colors['annual'], label='Annual', density=True)
    
    ax2.set_xlabel('Temperature (°C)', fontweight='bold')
    ax2.set_ylabel('Density', fontweight='bold')
    ax2.set_title('Temperature Distribution by Season', fontweight='bold')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_facecolor('#1a1a1a')
    
    # Plot 3: 2007 vs 2020 comparison (from monthly data)
    monthly_clean = df_monthly[~df_monthly['Avg. monthly Temp, Mendocino County(°F)'].str.contains('Winter|Spring', na=False)]
    months_short = [month[:3] for month in monthly_clean['Avg. monthly Temp, Mendocino County(°F)']]
    
    x_pos = np.arange(len(months_short))
    ax3.plot(x_pos, monthly_clean['2007 C'], marker='o', color=colors['winter'], 
            linewidth=2.5, markersize=8, label='2007')
    ax3.plot(x_pos, monthly_clean['2020 C'], marker='s', color=colors['spring'], 
            linewidth=2.5, markersize=8, label='2020')
    
    
    ax3.set_xlabel('Month', fontweight='bold')
    ax3.set_ylabel('Temperature (°C)', fontweight='bold')
    ax3.set_title('Monthly Comparison: 2007 vs 2020', fontweight='bold')
    ax3.set_xticks(x_pos)
    ax3.set_xticklabels(months_short)
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    ax3.set_facecolor('#1a1a1a')
    
    # Plot 4: Temperature change heatmap style
    changes = monthly_clean['diff C'].values.reshape(1, -1)
    im = ax4.imshow(changes, cmap='RdBu_r', aspect='auto', alpha=0.8)
    ax4.set_xticks(range(len(months_short)))
    ax4.set_xticklabels(months_short)
    ax4.set_yticks([])
    ax4.set_title('Temperature Change Heatmap (2020-2007)', fontweight='bold')
    
    # Add colorbar
    cbar = plt.colorbar(im, ax=ax4, orientation='horizontal', pad=0.1)
    cbar.set_label('Temperature Change (°C)', fontweight='bold')
    
    plt.tight_layout()
    return fig

def main():
    """Main function to create all plots"""
    print("Loading climate data...")
    df_data, df_monthly = load_data()
    
    print("Creating yearly temperature plot...")
    fig1 = create_yearly_temperature_plot(df_data)
    fig1.savefig('climate_yearly_trends.png', dpi=300, bbox_inches='tight', 
                facecolor='#1a1a1a', edgecolor='none')
    
    print("Creating monthly comparison plot...")
    fig2 = create_monthly_comparison_plot(df_monthly)
    fig2.savefig('climate_monthly_comparison.png', dpi=300, bbox_inches='tight',
                facecolor='#1a1a1a', edgecolor='none')
    
    print("Creating summary statistics plot...")
    fig3 = create_summary_statistics_plot(df_data, df_monthly)
    fig3.savefig('climate_summary_statistics.png', dpi=300, bbox_inches='tight',
                facecolor='#1a1a1a', edgecolor='none')
    
    plt.show()
    
    print("\nPlots created successfully!")
    print("Files saved:")
    print("- climate_yearly_trends.png")
    print("- climate_monthly_comparison.png") 
    print("- climate_summary_statistics.png")

if __name__ == "__main__":
    main()