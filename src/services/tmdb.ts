const TMDB_API_BASE_URL = 'https://api.themoviedb.org/3';
export const TMDB_IMAGE_BASE_URL = 'https://image.tmdb.org/t/p/w500';

export interface TMDBMovie {
  id: number;
  title: string;
  overview: string;
  poster_path: string | null;
  backdrop_path: string | null;
  release_date: string;
  vote_average: number;
  genre_ids: number[];
}

interface TMDBPopularResponse {
  page: number;
  results: TMDBMovie[];
  total_pages: number;
  total_results: number;
}

export const buildTmdbPosterUrl = (posterPath?: string | null): string | undefined => {
  if (!posterPath) {
    return undefined;
  }

  return `${TMDB_IMAGE_BASE_URL}${posterPath}`;
};

export const fetchRecommendations = async (page = 1): Promise<TMDBMovie[]> => {
  const accessToken = process.env.EXPO_PUBLIC_TMDB_ACCESS_TOKEN;

  if (!accessToken) {
    throw new Error('Missing EXPO_PUBLIC_TMDB_ACCESS_TOKEN environment variable.');
  }

  const endpoint = `${TMDB_API_BASE_URL}/movie/popular?language=en-US&page=${page}`;

  try {
    const response = await fetch(endpoint, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        Authorization: `Bearer ${accessToken}`,
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `TMDB request failed: ${response.status} ${response.statusText} - ${errorText}`
      );
    }

    const payload = (await response.json()) as TMDBPopularResponse;
    return Array.isArray(payload.results) ? payload.results : [];
  } catch (error) {
    console.error('Failed to fetch TMDB recommendations:', error);
    throw error;
  }
};
