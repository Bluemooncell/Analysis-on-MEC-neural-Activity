from mazepy.datastruc.neuact import NeuralTrajectory, SpikeTrain
from mylib.dsp.neural_traj import umap_dim_reduction, pca_dim_reduction, lda_dim_reduction
from mazepy.datastruc.variables import Variable1D
from mazepy.basic.convert import coordinate_recording_time
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA
import h5py
import numpy as np
import os
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import pickle
import pandas as pd
# -*- coding: utf-8 -*-
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.colors import LinearSegmentedColormap
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA
import h5py

from mazepy.datastruc.neuact import NeuralTrajectory, SpikeTrain
from mazepy.datastruc.variables import Variable1D


def read_data(data_dir):
    with h5py.File(data_dir, 'r') as f:
        f_mat = np.array(f['spike'])
        spike_time = f_mat[1, :]
        spike_dir = f_mat[6, :]
        neuron_id = f_mat[0, :].astype(np.int64)

    spikes = np.zeros((np.max(neuron_id), spike_time.shape[0]))
    for i in range(spike_time.shape[0]):
        spikes[neuron_id[i] - 1, i] = 1

    sort_idx = np.argsort(spike_time)
    spikes = spikes[:, sort_idx]
    spike_time = spike_time[sort_idx]
    spike_dir = spike_dir[sort_idx]
    spike_dir = Variable1D(spike_dir)
    spike_dir_bin = spike_dir.to_bin(0, 360, 120)

    spike_train = SpikeTrain(spikes, spike_time * 1000, spike_dir_bin)
    return spike_train.calc_neural_trajectory(1000, 100)


def MAE(y_pred, y_test):
    error = np.abs(y_test - y_pred) * 3
    error[error >= 180] = 360 - error[error >= 180]
    return np.mean(error)


def get_class_mean_vec(reduced_data, headdir_traj, dim=2):
    u_i = np.zeros((120, dim))
    for i in range(120):
        u_i[i, :] = np.mean(reduced_data[headdir_traj == i, :dim], axis=0)
    return u_i


def scatter_mat_analysis(headdir_traj, reduced_data):
    dim = 2
    u_i = get_class_mean_vec(reduced_data, headdir_traj, dim)
    u = np.mean(reduced_data[:, 0:dim], axis=0)
    S_W, S_B = np.zeros((dim, dim)), np.zeros((dim, dim))
    for i in range(120):
        for j in np.where(headdir_traj == i)[0]:
            a = reduced_data[j, :dim] - u_i[i, :]
            S_W += a[:, None] @ a[None, :]
        a = u_i[i, :] - u
        S_B += a[:, None] @ a[None, :] * np.sum(headdir_traj == i)
    return np.trace(S_B) / np.trace(S_W)


def get_fisher_discriminant(reduced_data, headdir_traj, conditions):
    fdrs = []
    for i in range(4):
        fdrs.append(scatter_mat_analysis(
            headdir_traj[conditions == i],
            reduced_data[conditions == i]
        ))
    return np.array(fdrs)


def separation_index(reduced_data, headdir_traj, conditions):
    SI = []
    for i in range(4):
        numerator = 0
        denominator = 0
        data = reduced_data[conditions == i]
        labels = headdir_traj[conditions == i]
        u_i = get_class_mean_vec(data, labels, dim=20)
        for j in range(120):
            for k in range(j + 1, 120):
                numerator += np.linalg.norm(u_i[j, :2] - u_i[k, :2])
            idx = np.where(labels == j)[0]
            denominator += np.sum([np.linalg.norm(data[k, :2] - u_i[j, :2]) for k in idx])
        SI.append(numerator / denominator if denominator != 0 else 0)
    return np.array(SI)


# def visualize_projection(reduced_data, headdir_traj, save_path):
#     cmap_base = plt.get_cmap('rainbow')
#     cmap = LinearSegmentedColormap.from_list('partial_rainbow', cmap_base(np.linspace(0.05, 0.75, 256)))
#     norm = mcolors.Normalize(vmin=0, vmax=119)
#     plt.figure(figsize=(4, 4))
#     sc = plt.scatter(reduced_data[:, 0], reduced_data[:, 1],
#                      c=headdir_traj, cmap=cmap, norm=norm, s=10, edgecolor='none')
#     plt.colorbar(sc, label='Head direction bin')
#     plt.axis('equal')
#     plt.axis((-8, 8, -8, 8))
#     plt.tight_layout()
#     plt.savefig(save_path + ".png", dpi=600)
#     plt.savefig(save_path + ".pdf", dpi=100)
#     plt.close()

def visualize_projection(reduced_data, headdir_traj, save_path):
    cmap_base = plt.get_cmap('rainbow')
    cmap = LinearSegmentedColormap.from_list('partial_rainbow', cmap_base(np.linspace(0.05, 0.75, 256)))
    norm = mcolors.Normalize(vmin=0, vmax=119)

    plt.figure(figsize=(4, 4))
    ax = plt.gca()
    mask = ~((reduced_data[:, 0] == 0) & (reduced_data[:, 1] == 0))
    reduced_data = reduced_data[mask]
    headdir_traj = headdir_traj[mask]
    sc = ax.scatter(
        reduced_data[:, 0],
        reduced_data[:, 1],
        c=headdir_traj,
        cmap=cmap,
        norm=norm,
        s=10,
        edgecolor='none'
    )

    ax.set_aspect('equal')
    ax.axis((-8, 8, -8, 8))

    cb = plt.colorbar(sc, ax=ax)
    cb.set_label("Head direction bin", rotation=270, labelpad=15)

    plt.tight_layout()
    plt.savefig(save_path + ".png", dpi=600)
    plt.savefig(save_path + ".pdf", dpi=300)
    plt.close()


def run_cross_projection(work_folder):
    print(f"Running LDA cross-projection in {work_folder}")
    save_path = os.path.join(work_folder, "baseline_projection")
    os.makedirs(save_path, exist_ok=True)

    data_files = [
        "spike_s1_light.mat",
        "spike_s2_dark.mat",
        "spike_s3_dark_whiskertrimmed.mat",
        "spike_s4_light_whiskertrimmed.mat"
    ]
    trajs = [read_data(os.path.join(work_folder, f)) for f in data_files]

    base_traj = trajs[0]
    base_X = base_traj.to_array().T
    base_y = base_traj.variable
    lda = LDA(n_components=20)
    lda.fit(base_X, base_y)

    projections = []
    maes = []
    all_conditions = []
    all_labels = []

    for i, traj in enumerate(trajs):
        X = traj.to_array().T
        y = traj.variable
        X_proj = lda.transform(X)
        y_pred = lda.predict(X)
        projections.append(X_proj)
        maes.append(MAE(y_pred, y))
        all_conditions.append(np.full(len(y), i))
        all_labels.append(y)
        visualize_projection(X_proj, y, os.path.join(save_path, f"session{i+1}"))

    proj_cat = np.vstack(projections)
    label_cat = np.concatenate(all_labels)
    cond_cat = np.concatenate(all_conditions)

    fdr = get_fisher_discriminant(proj_cat, label_cat, cond_cat)
    si = separation_index(proj_cat, label_cat, cond_cat)

    df = pd.DataFrame({
        'Session': [f'session{i+1}' for i in range(4)],
        'MAE': maes,
        'FDR': fdr,
        'SI': si
    })
    df.to_excel(os.path.join(work_folder, "Baseline_LDA_MAE_FDR_SI.xlsx"), index=False)
    print("Saved results to Baseline_LDA_MAE_FDR_SI.xlsx")


# === Run ===
dir_names = [
    r"D:\Test_code\Example_Data\49\20230127\HDfortrajectory",

]

for d in dir_names:
    run_cross_projection(d)

print("All mice done.")
